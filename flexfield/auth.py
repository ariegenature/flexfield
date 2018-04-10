"""Classes definitions for FlexField."""

from flask import current_app
from flask_login import AnonymousUserMixin, UserMixin

from flexfield.extensions import ldap_manager, login_manager


_OBJECT2LDAP = {  # Map Python attributes to LDAP attributes
    'username': 'uid',
    'display_name': 'displayName',
    'email': 'mail',
}

# Conversely, map LDAP attributes to Python attributes
_LDAP2OBJECT = dict((v, k) for k, v in _OBJECT2LDAP.items())

_REQ_ATTRS = set(_OBJECT2LDAP)


# View to redirect if a login is required
login_manager.login_view = 'flexfieldjs.login'


class User(UserMixin):
    """A FlexField user."""

    def __init__(self, username, display_name, email):
        self.username = username
        self.display_name = display_name
        self.email = email

    @property
    def is_active(self):
        """Return ``True`` if this user is active (aka. authenticated)."""
        return not isinstance(self, AnonymousUserMixin)

    @property
    def is_anonymous(self):
        """Return ``True`` if this user is anonymous."""
        return isinstance(self, AnonymousUserMixin)

    @property
    def is_authenticated(self):
        """Return ``True`` if this user is authenticated."""
        return self.is_active

    def get_id(self):
        """Return the user's identifier."""
        return self.username

    def __repr__(self):
        return self.username

    def __str__(self):
        return self.display_name


def new_user(**kwargs):
    """Factory function creating and returning a new ``User`` instance."""
    if not _REQ_ATTRS.issubset(set(kwargs)):
        raise ValueError('Unable to create user. Missing one of: {0}'.format(', '.join(_REQ_ATTRS)))
    return User(**{k: kwargs[k] for k in _OBJECT2LDAP if k in kwargs})


def _user_from_ldap_entry(ldap_dict):
    """Return a ``User`` instance from the given LDAP entry."""
    user_dict = dict()
    for ldapattr, pyattr in _LDAP2OBJECT.items():
        try:
            ldap_value = ldap_dict[ldapattr]
        except KeyError:
            continue
        ldap_value = ldap_value[0] if isinstance(ldap_value, list) else ldap_value
        user_dict[pyattr] = ldap_value
    return new_user(**user_dict)


@login_manager.user_loader
def load_user(username):
    try:
        return _user_from_ldap_entry(
            current_app.ldap3_login_manager.get_user_info_for_username(username)
        )
    except Exception:
        return None


@ldap_manager.save_user
def save_user(dn, username, ldap_dict, memberships):
    return _user_from_ldap_entry(ldap_dict)
