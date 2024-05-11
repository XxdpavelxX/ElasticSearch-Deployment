'''
Unittests for elasticsearch-cli.py
python -m pytest tests/test-elasticsearch-cli.py
'''

# pylint: disable=W1401
# pylint: disable=C0103

from unittest.mock import patch
from importlib import import_module

from click.testing import CliRunner

elasticsearch_cli = import_module("elasticsearch-cli")

def test_configure():
    r'''
    Test that the configure command runs aws configure.
    python .\elasticsearch-cli.py --configure
    '''
    runner = CliRunner()
    with patch('subprocess.check_output') as mocked_check_output:
        result = runner.invoke(elasticsearch_cli.run_terraform, ['--configure'])
        assert result.exit_code == 0
        mocked_check_output.assert_called_with(['aws', 'configure'])

def test_init():
    r'''
    Test that the init command runs terraform init.
    python .\elasticsearch-cli.py --init
    '''
    runner = CliRunner()
    with patch('subprocess.check_output') as mocked_check_output:
        result = runner.invoke(elasticsearch_cli.run_terraform, ['--init'])
        assert result.exit_code == 0
        mocked_check_output.assert_called_with(['terraform', '-chdir=environments/development',
                                                'init'])

def test_status():
    r'''
    Test that the status command runs terraform validate and terraform plan.
    python .\elasticsearch-cli.py --status
    '''
    runner = CliRunner()
    with patch('subprocess.check_output') as mocked_check_output:
        result = runner.invoke(elasticsearch_cli.run_terraform, ['--status'])
        assert result.exit_code == 0
        mocked_check_output.assert_any_call(['terraform', '-chdir=environments/development',
                                            'validate'])
        mocked_check_output.assert_called_with(['terraform', '-chdir=environments/development',
                                                'plan'])

def test_deploy():
    r'''
    Test that the deploy command runs terraform apply with auto-approve flag.
    python .\elasticsearch-cli.py --deploy
    '''
    runner = CliRunner()
    with patch('subprocess.check_output') as mocked_check_output:
        result = runner.invoke(elasticsearch_cli.run_terraform, ['--deploy'])
        assert result.exit_code == 0
        mocked_check_output.assert_called_with(['terraform', '-chdir=environments/development',
                                                'apply', '-auto-approve'])

def test_destroy():
    r'''
    Test that the destroy command runs terraform destroy with auto-approve flag.
    python .\elasticsearch-cli.py --destroy
    '''
    runner = CliRunner()
    with patch('subprocess.check_output') as mocked_check_output:
        result = runner.invoke(elasticsearch_cli.run_terraform, ['--destroy'])
        assert result.exit_code == 0
        mocked_check_output.assert_called_with(['terraform', '-chdir=environments/development',
                                                'destroy', '-auto-approve'])
