"""Flexfield resource for protocol 'ABC Montbel'."""

import os

from flexfield.resources import BaseFeatureCollectionResource
import flexfield


class ObservationResource(BaseFeatureCollectionResource):
    """Flask-Restful API endpoint to deal with observations."""

    get_sql = os.path.join(os.path.dirname(flexfield.__file__), 'sql', 'select_abc_montbel.sql')
    post_sql = os.path.join(os.path.dirname(flexfield.__file__), 'sql', 'insert_abc_montbel.sql')
    put_sql = os.path.join(os.path.dirname(flexfield.__file__), 'sql', 'update_abc_montbel.sql')

    def refined_features(self, collection):
        for feature in super().refined_features(collection):
            properties = feature['properties']
            if 'observers' not in properties or not properties['observers']:
                return ({'status': 400, 'message': 'At least one observer must be given'},
                        400)
            yield feature
