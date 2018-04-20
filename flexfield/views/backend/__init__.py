"""FlexField blueprint to communicate with backend."""

from functools import wraps
import os.path

from flask import Blueprint, abort, current_app, request, jsonify, redirect, url_for
from flask_login import current_user, login_required
from flask_login.config import EXEMPT_METHODS as LOGIN_EXEMPT_METHODS
import anosql
import psycopg2

import flexfield


backend_bp = Blueprint('backend', __name__, url_prefix='/backend')


def same_username_required(func):
    """Decorator for Flask view functions. The decorated view function must take ``username`` as its
    first parameter. Then this decorator will ensure that the currently logged in user has the same
    username (as returned by the ``get_id`` method) than the username passed when calling the view.
    """
    @wraps(func)
    def decorated_view(username, *args, **kwargs):
        if (request.method in LOGIN_EXEMPT_METHODS or current_app.login_manager._login_disabled):
            return func(username, *args, **kwargs)
        if current_user.is_authenticated and current_user.get_id() == username:
            return func(username, *args, **kwargs)
        if current_user.is_anonymous:
            return redirect(url_for('flexfieldjs.login'))
        return abort(403)
    return decorated_view


@backend_bp.route('/user')
@login_required
def user():
    """Return a JSON object describing user."""
    return jsonify({'username': current_user.username, 'display_name': current_user.display_name})


@backend_bp.route('/user-capabilities/<username>')
@same_username_required
def user_capabilities(username):
    """Return a JSON object describing user allowed studies, protocols and forms."""
    query = anosql.load_queries(
        'postgres',
        os.path.join(os.path.dirname(flexfield.__file__), 'sql', 'user_capabilities.sql')
    ).get_user_capabilities
    with psycopg2.connect(host=current_app.config['DB_HOST'],
                          port=current_app.config.get('DB_PORT', 5432),
                          user=current_app.config['DB_USER'],
                          password=current_app.config['DB_PASS'],
                          dbname=current_app.config['DB_NAME']) as cnx:
        res = {'username': username,
               'available_studies': []}
        known_studies = set()
        known_protocols = set()
        studies = res['available_studies']
        for row in query(cnx, username=username):
            (
                study_code,
                study_title,
                study_short_title,
                study_description,
                study_pictogram,
                protocol_code,
                protocol_title,
                protocol_short_title,
                protocol_description,
                protocol_pictogram,
                form_code,
                form_title,
                form_short_title,
                form_description,
                form_pictogram,
                form_component_name,
                form_yaml_description,
                nop_form_code,
                nop_form_title,
                nop_form_short_title,
                nop_form_description,
                nop_form_pictogram,
                nop_form_component_name,
                nop_form_yaml_description,
            ) = row
            if study_code not in known_studies:
                studies.append({
                    'type': 'study',
                    'code': study_code,
                    'title': study_title,
                    'short_title': study_short_title,
                    'description': study_description,
                    'pictogram': study_pictogram,
                    'protocols': [],
                })
                known_studies.add(study_code)
            study = studies[-1]  # This assumes that results are ordered by study_code first
            protocols = study['protocols']
            if protocol_code is not None and protocol_code not in known_protocols:
                protocols.append({
                    'type': 'protocol',
                    'code': protocol_code,
                    'title': protocol_title,
                    'short_title': protocol_short_title,
                    'description': protocol_description,
                    'pictogram': protocol_pictogram,
                    'forms': [],
                })
                known_protocols.add(protocol_code)
            if protocol_code is None and 'NOP' not in known_protocols:
                protocols.append({
                    'type': 'protocol',
                    'code': 'NOP',
                    'pictogram': 'https://ariegenature.fr/wp-content/uploads/2018/04/empty.png',
                    'forms': [],
                })
                known_protocols.add('NOP')
            protocol = protocols[-1]  # This assumes that results are ordered by protocol_code too
            forms = protocol['forms']
            forms.append({
                'type': 'form',
                'code': form_code or nop_form_code,
                'title': form_title or nop_form_title,
                'short_title': form_short_title or nop_form_short_title,
                'description': form_description or nop_form_description,
                'pictogram': form_pictogram or nop_form_pictogram,
                'component_name': form_component_name or nop_form_component_name,
                'yaml_description': form_yaml_description or nop_form_yaml_description,
            })
    return jsonify(res)
