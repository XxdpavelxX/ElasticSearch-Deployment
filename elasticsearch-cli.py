#! /usr/bin/env python3
'''
Runs terraform commands to manage AWS resources
for ElasticSearch deployment.

Sample Run:
python elasticsearch-cli.py --init
python elasticsearch-cli.py --status
python elasticsearch-cli.py --deploy
python elasticsearch-cli.py --destroy
'''

# pylint: disable=E1120
# pylint: disable=C0103
# pylint: disable=R0913

import logging
import subprocess

import click

@click.command()
@click.option('-c', '--configure', is_flag=True, help='Run aws configure to set target AWS account')
@click.option('-i', '--init', is_flag=True, help='Run terraform init for ES deployment')
@click.option('-s', '--status', is_flag=True, help='Run terraform plan for ES deployment')
@click.option('-d', '--deploy', is_flag=True, help='Run terraform apply for ES deployment')
@click.option('-e', '--destroy', is_flag=True, help='Run terraform destroy for ES deployment')
@click.option('-l', '--log_level', type=click.STRING, default='INFO',
              help='''Sets the log level of the script. Defaults to INFO.
              Can be set to Can be DEBUG, WARNING, ERROR, or CRITICAL''')
def run_terraform(init, status, deploy, destroy, configure, log_level: str) -> None:
    '''
    Run terraform commands to manage AWS resources for ElasticSearch deployment.\n

    :param configure: {bool object}: When passed runs 'aws configure' to set target AWS account
    :param init: {bool object}: When passed runs 'terraform init' for ElasticSearch deployment
    :param status: {bool object}: When passed runs 'terraform plan' for ElasticSearch deployment
    :param deploy: {bool object}: When passed runs 'terraform apply' for ElasticSearch deployment
    :param destroy: {bool object}: When passed runs 'terraform destroy' for ElasticSearch deployment
    :param log_level: {str object}: Sets the log level of the script. Can be 'DEBUG', 'INFO',
    'WARNING', 'ERROR', or 'CRITICAL'. Defaults to 'INFO'
    :return: None
    '''
    logging.basicConfig(format='%(asctime)s - Terraform Output - %(levelname)s \n %(message)s',
                        level=str(log_level.upper()))
    logging.info("Starting Terraform script to manage AWS resources for ElasticSearch deployment.")

    if sum([init, status, deploy, destroy, configure]) > 1:
        error_message = "You can only pass one command (ie --init, --plan, --deploy, or --destroy)."
        logging.error(error_message)
        raise click.UsageError(error_message)

    if sum([init, status, deploy, destroy, configure]) == 0:
        error_message = "Requires at least one command (ie --init, --plan, --deploy, or --destroy)."
        logging.error(error_message)
        raise click.UsageError(error_message)

    aws_configure = ["aws", "configure"]
    terr_init = ["terraform",
        "-chdir=environments/development",
        "init",
        ]
    terr_validate = ["terraform",
        "-chdir=environments/development",
        "validate",
        ]
    terr_plan = ["terraform",
        "-chdir=environments/development",
        "plan",
        ]
    terr_apply = ["terraform",
        "-chdir=environments/development",
        "apply",
        "-auto-approve"
        ]
    terr_destroy = ["terraform",
        "-chdir=environments/development",
        "destroy",
        "-auto-approve"
        ]

    if configure:
        logging.info("""Running aws configure to set target AWS account. Please pass AWS Access Key
                     ID, then Secret Access Key, then AWS region,and lastly press enter.""")
        run_terraform_capture_logs(aws_configure)
        logging.info("AWS environment successfully configured.")
    if init:
        logging.info("Running terraform init")
        run_terraform_capture_logs(terr_init)
        logging.info("AWS environment successfully initialized for deployments.")

    elif status:
        logging.info("Running terraform validate")
        run_terraform_capture_logs(terr_validate)
        logging.info("Running terraform validate")
        run_terraform_capture_logs(terr_plan)

    elif deploy:
        logging.info("Running terraform deploy, please wait a couple minutes to complete.")
        run_terraform_capture_logs(terr_apply)
        logging.info("""completed deploying AWS resources, please wait ~5 minutes for
                     ES to load before sending requests it.""")

    elif destroy:
        logging.info("""Running terraform destroy, please wait a couple
                     minutes for the resources to be deleted.""")
        run_terraform_capture_logs(terr_destroy)
        logging.info("Destroying ElasticSearch AWS resources complete.")

def run_terraform_capture_logs(terraform_command: list) -> None:
    '''Runs specified terraform command and captures output for logs.
      Also converts output from byte to string'''
    try:
        output = subprocess.check_output(terraform_command)
        logging.info(output.decode())
    except subprocess.CalledProcessError as e:
        logging.error(e.output.decode())

if __name__ == '__main__':
    run_terraform()
