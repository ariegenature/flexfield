# To use this script with Flask, you should assign its path to the FLASK_APP environment variable
#
#     > export FLASK_APP=/path/to/flexfield_cli.py
#
# then you can simply run `flask run`. See <http://flask.pocoo.org/docs/0.12/cli/> for more
# information.

import csv
import glob
import io
import os
import subprocess
import re

from flask import current_app
import click
import psycopg2

from flexfield import create_app, read_config
import flexfield


_SINP_TNAME = {
    '2-DS_PUBLIQUE': 'data_type',
    '3-NAT_OBJ_GEO': 'presence_type',
    '5-NIV_PRECIS': 'blur_level',
    '6-OBJ_DENBR': 'subject_type',
    '7-ETA_BIO': 'living_status',
    '8-NATURALITE': 'domestication_status',
    '9-SEXE': 'gender',
    '10-STADE_VIE': 'age',
    '11-STAT_BIOGEO': 'biogeographical_status',
    '12-REF_HAB': 'habitat_reference',
    '13-STATUT_BIO': 'biological_status',
    '14-METH_OBS': 'observation_method',
    '15-PREUVE_EXIST': 'evidence',
    '16-SENSIBILITE': 'sensitivity_level',
    '18-STATUT_OBS': 'presence',
    '19-STATUT_SOURCE': 'data_source',
    '21-DENBR': 'count_method',
    '22-TYP_EN': 'protected_area_type',
    '23-TYP_INF_GEO': 'georeferencing_type',
    '24-TYP_GRP': 'merging_type',
    '25-VERS_ME': 'waterbody_ref_version',
}

_SINP_FNAME_REGEXP = re.compile(r'(\d+-[^-]+)-\d+-\d+-\d+\.csv$')


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


@app.cli.command(name='import-sinp-vocabularies')
@click.option('--folder', help='Folder containing SINPN vocabularies CSV files')
def import_sinp_vocabularies(folder):
    """Import SINP controlled vocabularies from given folder.

    The folder must contains controlled vocabularies in CSV files.
    """
    folder = os.path.expanduser(folder)
    click.echo('-> Importing SINP vocabularies from folder {0}...'.format(os.path.abspath(folder)))
    with psycopg2.connect(host=current_app.config['DB_HOST'],
                          port=current_app.config.get('DB_PORT', 5432),
                          user=current_app.config['DB_USER'],
                          password=current_app.config['DB_PASS'],
                          dbname=current_app.config['DB_NAME']) as cnx:
        for fpath in glob.glob(os.path.join(folder, '*.csv')):
            fname = os.path.basename(fpath)
            match = _SINP_FNAME_REGEXP.match(fname)
            if not match:
                click.echo('  Ignoring not SINP file {0}'.format(fname))
                continue
            match = match.group(1)
            if match not in _SINP_TNAME:
                click.echo('  Ignoring file {0}'.format(fname))
                continue
            tname = _SINP_TNAME[match]
            with open(fpath) as f:
                dialect = csv.Sniffer().sniff(f.readline())
                f.seek(0)
                reader = csv.DictReader(f, dialect=dialect)
                tsv = io.StringIO()
                writer = csv.writer(tsv, delimiter='\t')
                for row in reader:
                    writer.writerow([row['\ufeff"Code"'], row['Libellé'], row['Définition']])
            tsv.seek(0)
            with cnx.cursor() as cur:
                cur.copy_from(tsv, 'ref.{0}'.format(tname))
    click.echo('-> SINP vocabularies successfully imported.')
