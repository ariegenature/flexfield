"""Flexfield resource for protocol 'ABC Montbel'."""

import json
import os

from flask import current_app
from flask_restful import Resource, reqparse
import anosql
import psycopg2

import flexfield


class ObservationResource(Resource):
    """Flask-Restful API endpoint to deal with observations."""

    def __init__(self):
        self.post_parser = reqparse.RequestParser()
        self.post_parser.add_argument('form', required=True, nullable=False,
                                      help='Code of the form used to POST data')
        self.post_parser.add_argument('feature', type=dict, required=True,
                                      nullable=False, help='GeoJSON feature to insert')

    def post(self):
        observation_dict = self.post_parser.parse_args(strict=True)
        insert_dict = dict()
        insert_dict['geometry'] = json.dumps(observation_dict['feature']['geometry'])
        insert_dict.update(observation_dict['feature']['properties'])
        insert_observation = anosql.load_queries(
            'postgres',
            os.path.join(os.path.dirname(flexfield.__file__), 'sql', 'insert_abc_montbel.sql')
        ).insert_observation_auto
        insert_observer = anosql.load_queries(
            'postgres',
            os.path.join(os.path.dirname(flexfield.__file__), 'sql', 'insert_abc_montbel.sql')
        ).insert_observer
        with psycopg2.connect(host=current_app.config['DB_HOST'],
                              port=current_app.config.get('DB_PORT', 5432),
                              user=current_app.config['DB_USER'],
                              password=current_app.config['DB_PASS'],
                              dbname=current_app.config['DB_NAME']) as cnx:
            obs_id = insert_observation(cnx, **insert_dict)
            for name in insert_dict['observers']:
                insert_observer(cnx, obs_id=obs_id, name=name)

    def get(self):
        query = anosql.load_queries(
                'postgres',
                os.path.join(os.path.dirname(flexfield.__file__), 'sql',
                             'select_abc_montbel.sql')
        ).get_observations
        with psycopg2.connect(host=current_app.config['DB_HOST'],
                              port=current_app.config.get('DB_PORT', 5432),
                              user=current_app.config['DB_USER'],
                              password=current_app.config['DB_PASS'],
                              dbname=current_app.config['DB_NAME']) as cnx:
            rows = query(cnx)
        # build response
        res = {
            'type': 'FeatureCollection',
            'features': []
        }
        features = res['features']
        for row in rows:
            (obs_id, observation_date, observers, taxon, observation_method, has_picture, is_confident,
             comments, geometry) = row
            features.append({
                'type': 'Feature',
                'id': obs_id,
                'properties': {
                    'observation_date': observation_date.strftime('%Y-%m-%d'),
                    'taxon': taxon,
                    'observation_method': observation_method,
                    'has_picture': has_picture,
                    'is_confident': is_confident,
                    'comments': comments,
                    'observers': [name.strip() for name in observers.split(',')]
                },
                'geometry': json.loads(geometry)
            })
        return res
