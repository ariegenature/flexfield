"""FlexField package for views and blueprints."""

from flask import redirect, url_for

from flexfield.views.flexfieldjs import flexfieldjs_bp


blueprints = [flexfieldjs_bp]


def home():
    """FlexField homepage."""
    return redirect(url_for('flexfieldjs.index'))
