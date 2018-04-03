"""FlexField blueprint for its JavaScript client."""

import mimetypes

from flask import Blueprint, current_app, make_response, render_template


flexfieldjs_bp = Blueprint('flexfieldjs', __name__, template_folder='templates',
                           static_folder='templates/static')


@flexfieldjs_bp.route('/webcli')
def index():
    return render_template('vue/index.html', site_title=current_app.config['SITE_TITLE'])


@flexfieldjs_bp.route('/webcli/static/<path:fpath>')
def contribute_static(fpath):
    resp = make_response(render_template('static/{0}'.format(fpath)))
    resp.headers['Content-Type'], resp.headers['Content-Encoding'] = mimetypes.guess_type(fpath)
    return resp
