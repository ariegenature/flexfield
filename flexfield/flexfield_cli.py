# To use this script with Flask, you should assign its path to the FLASK_APP environment variable
#
#     > export FLASK_APP=/path/to/flexfield_cli.py
#
# then you can simply run `flask run`. See <http://flask.pocoo.org/docs/0.12/cli/> for more
# information.

import os
import subprocess

import click

from flexfield import create_app, read_config
import flexfield

config = read_config()
app = create_app(config)


@app.cli.command(name='install-js-deps')
def install_js_deps():
    """Run ``npm install`` for the Vue.js client in order to install its JavaScript dependencies."""
    click.echo('-> Installing JavaScript dependencies for the Vue.js client...')
    subprocess.check_call(['npm',
                           '--prefix={0}'.format(os.path.join(os.path.dirname(flexfield.__file__),
                                                              'flexfieldjs')),
                           'install'])
    click.echo('-> JavaScript dependencies succesfully installed.')


@app.cli.command(name='build-js-client')
def build_js_client():
    """Execute ``npm run build`` for the Vue.js client to build it so that it can be served."""
    click.echo('-> Building the Vue.js client...')
    subprocess.check_call(['npm',
                           '--prefix={0}'.format(os.path.join(os.path.dirname(flexfield.__file__),
                                                              'flexfieldjs')),
                           'run',
                           'build'])
    click.echo('-> Vue.js client succesfully built.')
