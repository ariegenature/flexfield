"""FlexField blueprint for its JavaScript client."""

import mimetypes

from flask import Blueprint, current_app, make_response, redirect, render_template, request, url_for
from flask_ldap3_login.forms import LDAPLoginForm
from flask_login import current_user, login_required, login_user

from flexfield.utils import is_safe_url

flexfieldjs_bp = Blueprint('flexfieldjs', __name__, template_folder='templates',
                           static_folder='templates/static')


@flexfieldjs_bp.route('/webcli')
@login_required
def index():
    return render_template('vue/index.html', site_title=current_app.config['SITE_TITLE'])


@flexfieldjs_bp.route('/webcli/static/<path:fpath>')
def contribute_static(fpath):
    resp = make_response(render_template('static/{0}'.format(fpath)))
    resp.headers['Content-Type'], resp.headers['Content-Encoding'] = mimetypes.guess_type(fpath)
    return resp


@flexfieldjs_bp.route('/login', methods=['GET', 'POST'])
def login():
    if current_user.is_authenticated:
        return _redirect_next_or_index(request)
    form = LDAPLoginForm()
    if form.validate_on_submit():
        login_user(form.user)
        return _redirect_next_or_index(request)
    return render_template('vue/index.html', site_title=current_app.config['SITE_TITLE'])


def _redirect_next_or_index(req):
    """Redirect to URL given by ``next`` parameter or to homepage if there is no ``next`` parameter
    or if it is not a safe URL."""
    next_url = req.args.get('next')
    if not is_safe_url(next_url):
        next_url = None
    return redirect(next_url or url_for('.index'))
