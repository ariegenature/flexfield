"""Some Python tools for Flexfield."""

from urllib.parse import urlparse, urljoin

from flask import request


def is_safe_url(target):
    """Return ``True`` if target is a safe URL for FlexField."""
    ref_url = urlparse(request.host_url)
    test_url = urlparse(urljoin(request.host_url, target))
    return test_url.scheme in ('http', 'https') and ref_url.netloc == test_url.netloc
