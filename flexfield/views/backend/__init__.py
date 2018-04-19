"""FlexField blueprint to communicate with backend."""

from functools import wraps

from flask import Blueprint, abort, current_app, request, jsonify, redirect, url_for
from flask_login import current_user
from flask_login.config import EXEMPT_METHODS as LOGIN_EXEMPT_METHODS


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


@backend_bp.route('/user_capabilities/<username>')
@same_username_required
def user_capabilities(username):
    """Return a JSON object describing user allowed studies, protocols and forms."""
    return jsonify({'username': username})
