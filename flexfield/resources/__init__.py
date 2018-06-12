"""Flexfield resources."""

from functools import wraps
import json

from flask import jsonify
from flask_login import current_user

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
