"""Flexfield resource for protocol 'ABC Montbel'."""

import os

from flexfield.resources import BaseFeatureCollectionResource
import flexfield


class ObservationResource(BaseFeatureCollectionResource):
    """Flask-Restful API endpoint to deal with observations."""

    post_sql = os.path.join(os.path.dirname(flexfield.__file__), 'sql', 'insert_abc_montbel.sql')
    get_sql = os.path.join(os.path.dirname(flexfield.__file__), 'sql', 'select_abc_montbel.sql')

    def collection_to_rows(self, collection):
        for row in super().collection_to_rows(collection):
            row['dc_title'] = 'Observation du {date}'.format(date=row['observation_date'])
            if not row['observers']:
                return ({'status': 400, 'message': 'At least one observer must be given'},
                        400)
            yield row
