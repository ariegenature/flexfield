"""Flexfield resource for protocol 'ABC Montbel'."""

import json
import os

from flask import current_app
from flask_login import current_user
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
        feature = dict()
        feature['geometry'] = json.dumps(observation_dict['feature']['geometry'])
        feature.update(observation_dict['feature']['properties'])
        feature['dc_creator'] = current_user.username
        feature['dc_title'] = 'Observation du {date}'.format(date=feature['observation_date'])
        if feature['count_max'] is None:
            feature['count_max'] = feature['count_min']
        if feature['count_max'] < feature['count_min']:
            return ({'status': 400, 'message': 'Maximum count must be greater that minimum count'},
                    400)
        if not feature['observers']:
            return ({'status': 400, 'message': 'At least one observer must be given'},
                    400)
        insert_observation = anosql.load_queries(
            'postgres',
            os.path.join(os.path.dirname(flexfield.__file__), 'sql', 'insert_abc_montbel.sql')
        ).insert_observation
        with psycopg2.connect(host=current_app.config['DB_HOST'],
                              port=current_app.config.get('DB_PORT', 5432),
                              user=current_app.config['DB_USER'],
                              password=current_app.config['DB_PASS'],
                              dbname=current_app.config['DB_NAME']) as cnx:
            insert_observation(cnx, feature=json.dumps(feature))

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
            (obs_id, observation_date, observers, taxon, observation_method, count_min, count_max,
             count_method, comments, grid_cell, geometry) = row
            count_str = ('{min_}-{max_}'.format(min_=count_min, max_=count_max)
                         if count_min < count_max
                         else str(count_min))
            count_str = ('{s} [{method}]'.format(s=count_str, method=count_method)
                         if count_method in ('Compté', 'Calculé')
                         else '~ {s}'.format(s=count_str))
            features.append({
                'type': 'Feature',
                'id': obs_id,
                'properties': {
                    'observation_date': observation_date.strftime('%Y-%m-%d'),
                    'subject': taxon,
                    'observers': ', '.join(observers),
                    'Type de contact': observation_method,
                    'Effectif': count_str,
                    'Remarques': comments,
                    'Maille': grid_cell,
                },
                'geometry': json.loads(geometry)
            })
        return res
