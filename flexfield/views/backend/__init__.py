"""FlexField blueprint to communicate with backend."""

from flask import Blueprint


backend_bp = Blueprint('backend', __name__, url_prefix='/backend')
