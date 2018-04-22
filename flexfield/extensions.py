"""Extensions used by flexfield."""

from flask_ldap3_login import LDAP3LoginManager
from flask_login import LoginManager
from flask_restful import Api
from flask_wtf.csrf import CSRFProtect


csrf = CSRFProtect()
ldap_manager = LDAP3LoginManager()
login_manager = LoginManager()
rest_api = Api()
