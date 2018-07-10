"""Flexfield resources."""

from abc import ABC, ABCMeta, abstractmethod

from functools import wraps
import json

from flask import current_app, jsonify, request
from flask.views import MethodViewType
from flask_login import current_user
from flask_restful import Resource, reqparse
import anosql
import psycopg2

from flexfield.views.backend import user_capabilities


role_permissions = {
    'type': 'role_permissions',
    'role_permissions': [
        {
            'role': 'Manager',
            'permissions': [
                {
                    'not_null_property': 'none',
                    'can_edit': 'all',
                },
                {
                    'not_null_property': 'dc_date_submitted',
                    'can_edit': 'all',
                },
                {
                    'not_null_property': 'dc_date_accepted',
                    'can_edit': 'all',
                },
                {
                    'not_null_property': 'dc_date_issued',
                    'can_edit': 'all',
                }
            ]
        },
        {
            'role': 'Collaborator',
            'permissions': [
                {
                    'not_null_property': 'none',
                    'can_edit': 'all',
                },
                {
                    'not_null_property': 'dc_date_submitted',
                    'can_edit': 'all',
                },
                {
                    'not_null_property': 'dc_date_accepted',
                    'can_edit': 'all',
                },
                {
                    'not_null_property': 'dc_date_issued',
                    'can_edit': False,
                }
            ]
        },
        {
            'role': 'Contributor',
            'permissions': [
                {
                    'not_null_property': 'none',
                    'can_edit': 'own',
                },
                {
                    'not_null_property': 'dc_date_submitted',
                    'can_edit': 'own',
                },
                {
                    'not_null_property': 'dc_date_accepted',
                    'can_edit': False,
                },
                {
                    'not_null_property': 'dc_date_issued',
                    'can_edit': False,
                }
            ]
        },
        {
            'role': 'Viewer',
            'permissions': [
                {
                    'not_null_property': 'none',
                    'can_edit': False,
                },
                {
                    'not_null_property': 'dc_date_submitted',
                    'can_edit': False,
                },
                {
                    'not_null_property': 'dc_date_accepted',
                    'can_edit': False,
                },
                {
                    'not_null_property': 'dc_date_issued',
                    'can_edit': False,
                }
            ]
        }
    ]
}


def add_permissions(f):
    """Decorator for a ``GET`` REST view returning a GeoJSON feature collection.

    The decorator will add a new property on each feature in the collection, ``can_edit``, which
    can be ``True`` or ``False``, depending on the current user role in the study.
    """
    @wraps(f)
    def wrapper(*args, **kwargs):
        feature_coll = f(*args, **kwargs)
        caps = json.loads(user_capabilities(current_user.username).get_data())
        studies = caps['available_studies']
        for feature in feature_coll['features']:
            properties = feature['properties']
            properties['can_edit'] = False  # default: cannot edit
            study = filter(lambda study: study['code'] == properties['study'], studies)
            study = next(study, None)
            if study is None:
                continue
            permissions = next(
                filter(lambda rp: rp['role'] == study['role'], role_permissions['role_permissions'])
            )['permissions']
            for dc_date_prop in ('dc_date_issued', 'dc_date_accepted', 'dc_date_submitted', 'none'):
                if dc_date_prop != 'none' and properties[dc_date_prop] is None:
                    continue
                edit_perm = next(
                    filter(lambda pp: pp['not_null_property'] == dc_date_prop, permissions)
                )['can_edit']
                if edit_perm == 'all':
                    properties['can_edit'] = True
                elif edit_perm == 'own' and properties['dc_creator'] == current_user.username:
                    properties['can_edit'] = True
                else:
                    properties['can_edit'] = False
        return jsonify(feature_coll)
    return wrapper


def _feature(feature):
    """Returns the given dict as-is if it is a GeoJSON feature, else raise a ``ValueError``.

    This function can be used by a Flask-Restful request parser as the ``type`` parameter of the ``add_argument`` method
    to check that ``POST`` data is a valid GeoJSON feature.
    """
    try:
        if feature['type'] != 'Feature':
            raise ValueError()
        feature['properties']
        feature['geometry']
    except (TypeError, ValueError, KeyError):
        raise ValueError('{0} is not a valid GeoJSON feature'.format(feature))
    return feature


class _ABCMetaViewType(ABCMeta, MethodViewType):
    """Combines metaclasses for `abc.ABC` and `flask.views.MethodViewType`."""
    pass


class BaseFeatureCollectionResource(ABC, Resource, metaclass=_ABCMetaViewType):
    """Abstract Flask-Restful API endpoint to deal with GeoJSON feature collections."""

    post_sql = None
    get_sql = None

    def __init__(self):
        self.post_parser = reqparse.RequestParser()
        self.post_parser.add_argument('type', required=True, nullable=False, choices=('FeatureCollection',),
                                      location='json', help='Type of the GeoJSON object (must be: FeatureCollection)')
        self.post_parser.add_argument('features', type=_feature, required=True, nullable=False, action='append',
                                      location='json', help='GeoJSON feature(s) to insert')

    @abstractmethod
    def collection_to_rows(self, collection):
        """Yield each GeoJSON feature in the given feature collection as a JSON object.

        The JSON object is to be inserted/updated into a PostgreSQL/Posgis database using the ``jsonb_populate_record``
        function."""
        for feature in collection['features']:
            row = dict()
            row['geometry'] = json.dumps(feature['geometry'])
            row.update(feature['properties'])
            row['dc_creator'] = current_user.username
            if feature['properties']['study'] == 'NOS':
                row['study'] = None
            if feature['properties']['protocol'] == 'NOP':
                row['protocol'] = None
            yield row

    def post(self):
        collection = self.post_parser.parse_args(strict=True)
        post_query = getattr(anosql.load_queries('postgres', self.post_sql),
                             request.path.split('/')[-1].replace('-', '_'))
        with psycopg2.connect(host=current_app.config['DB_HOST'],
                              port=current_app.config.get('DB_PORT', 5432),
                              user=current_app.config['DB_USER'],
                              password=current_app.config['DB_PASS'],
                              dbname=current_app.config['DB_NAME']) as cnx:
            for row in self.collection_to_rows(collection):
                print(json.dumps(row, indent=2, sort_keys=True))
                post_query(cnx, feature=json.dumps(row))

    def get(self):
        get_query = getattr(anosql.load_queries('postgres', self.get_sql),
                            request.path.split('/')[-1].replace('-', '_'))
        with psycopg2.connect(host=current_app.config['DB_HOST'],
                              port=current_app.config.get('DB_PORT', 5432),
                              user=current_app.config['DB_USER'],
                              password=current_app.config['DB_PASS'],
                              dbname=current_app.config['DB_NAME']) as cnx:
            rows = get_query(cnx)
        rows = [row[0] for row in rows]
        # build response
        res = {
            'type': 'FeatureCollection',
            'features': []
        }
        features = res['features']
        for row in rows:
            feature = {'type': 'Feature', 'id': row['id']}
            feature['properties'] = {k: v for k, v in row.items() if k not in ('id', 'geometry', 'wfs_geometry')}
            feature['geometry'] = json.loads(row['geometry'])
            features.append(feature)
        return res
