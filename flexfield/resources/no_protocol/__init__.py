"""Flexfield resource for no protocol forms."""

import json
import os

from flask import current_app, request
from flask_login import current_user
import anosql
import psycopg2

from flexfield.resources import BaseFeatureCollectionResource
import flexfield


class CatchAllResource(BaseFeatureCollectionResource):
    """Flask-Restful API endpoint to deal with catch all observations."""

    def collection_to_rows(collection):
        for row in super(collection):
            row['dc_title'] = 'Observation du {date}'.format(date=row['observation_period_beginning'])
            if not row['observers']:
                return ({'status': 400, 'message': 'At least one observer must be given'},
                        400)

    def post(self):
        observation_dict = self.post_parser.parse_args(strict=True)
        feature = dict()
        feature['geometry'] = json.dumps(observation_dict['feature']['geometry'])
        feature.update(observation_dict['feature']['properties'])
        feature['dc_creator'] = current_user.username
        feature['dc_title'] = 'Observation du {date}'.format(date=feature['observation_period_beginning'])
        if feature['study'] == 'NOS':
            feature['study'] = None
        if feature['protocol'] == 'NOP':
            feature['protocol'] = None
        insert_observation = getattr(anosql.load_queries(
            'postgres',
            os.path.join(os.path.dirname(flexfield.__file__), 'sql', 'insert_no_protocol.sql')
        ), request.path.split('/')[-1].replace('-', '_'))
        with psycopg2.connect(host=current_app.config['DB_HOST'],
                              port=current_app.config.get('DB_PORT', 5432),
                              user=current_app.config['DB_USER'],
                              password=current_app.config['DB_PASS'],
                              dbname=current_app.config['DB_NAME']) as cnx:
            insert_observation(cnx, feature=json.dumps(feature))

    def get(self):
        query = getattr(anosql.load_queries(
                'postgres',
                os.path.join(os.path.dirname(flexfield.__file__), 'sql',
                             'select_no_protocol.sql')
        ), request.path.split('/')[-1].replace('-', '_'))
        with psycopg2.connect(host=current_app.config['DB_HOST'],
                              port=current_app.config.get('DB_PORT', 5432),
                              user=current_app.config['DB_USER'],
                              password=current_app.config['DB_PASS'],
                              dbname=current_app.config['DB_NAME']) as cnx:
            rows = query(cnx)
        rows = [row[0] for row in rows]
        # build response
        res = {
            'type': 'FeatureCollection',
            'features': []
        }
        features = res['features']
        for row_dict in rows:
            feature = {'type': 'Feature', 'id': row_dict['id']}
            feature['properties'] = {k: v for k, v in row_dict.items() if k not in ('id', 'geometry', 'wfs_geometry')}
            feature['geometry'] = json.loads(row_dict['geometry'])
            features.append(feature)
        return res
