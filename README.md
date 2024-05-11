## Setup and Installation instructions
1. Make sure you have installed Python3 and pip on your machine.
Python3: https://www.python.org/downloads/
Pip: https://pip.pypa.io/en/stable/installation/

2. Make sure you have installed Terraform (tested here with version 1.7.4).
https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli

3. Install python dependencies.
pip install -r requirements.txt

4. Create an AWS user for terraform that has required permissions to deploy the required ElasticSearch AWS resources.
For this demo/test I decided to just give it admin permissions to keep things simple. Get that users AWS ACCESS KEY ID and AWS ACCESS KEY SECREt. You will need to use these later.

5. Set the AWS account to be used for the ES deployment. Will need to pass AWS Access Key, Secret Access Key, and AWS region
that you got earlier, in that order then press enter (Currently does not tell you what values you need to input)
python .\elasticsearch-cli.py --configure (runs aws configure)

or
Manually modify ~/.aws (or your shell's profile) with desired AWS Access keys

or just export the access keys
export AWS_ACCESS_KEY_ID='Your Access Key ID'
export AWS_SECRET_ACCESS_KEY='Your Secret Access Key'

6. Initialize AWS account for resource deployment
python .\elasticsearch-cli.py --init

#### Optional
1. Install the AWS CLI. This is used mainly configure your computer to run AWS requests in specific accounts, regions.
https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

2. Install Python Venv (virtual env) to separate python requirements from CLI.
https://virtualenv.pypa.io/en/latest/installation.html


### Running and deploying Elasticsearch
1. Deploy ElasticSearch and all required AWS resources. Returns URL for ElasticSearch deployment.This may take approximately 2 minutes. Note: Please wait ~5 minutes for ElasticSearch to bootstrap and start running after deployment completes. You can then make curl requests to the URL returned (see "Sample Curl commands to test deployment" section).
python .\elasticsearch-cli.py --deploy

2. Delete ElasticSearch and all associated AWS resources. This may take approximately 2 minutes.
python .\elasticsearch-cli.py --destroy

3. Validate that ElasticSearch deployment is valid and whether all required AWS resources are deployed.
python .\elasticsearch-cli.py --status

4. Initialize AWS account for resource deployment
python .\elasticsearch-cli.py --init

5. Sets the AWS account to be used for the ES deployment. Will need to pass AWS Access Key, Secret Access Key, and AWS region
that you got earlier, in that order then press enter (Currently does not tell you what values you need to input). This just runs "aws configure".
python .\elasticsearch-cli.py --configure

6. Recieve additional information about available CLI commands
python .\elasticsearch-cli.py --help

#### Sample Curl commands to test deployment:

ElasticSearch basic commands (without -X if on windows):
Basic health request: curl <ip_address>:9200
List ElasticSearch indexes: curl -X GET <ip_address>:9200/_cat/indices?v'
List docs in an index: curl -X GET '<ip_address>:9200/sample/_search'
Get health status of ElasticSearch cluster: curl -X GET <ip_address>:9200/_cluster/health?pretty
Create an index called products: curl -X PUT <ip_address>:9200/products

Additional ElasticSearch endpoints: https://www.bmc.com/blogs/elasticsearch-commands/

### Design
![Alt text](/ElasticSearch-Design.jpg?raw=true "ElasticSearch Deployment Architecture")

## Discussion
### Security
- Currently the deployment here is not very secure since this is a dev deployment meant for demo and testing purposes. The server that gets deployed is running on a public subnet and open to the internet on ports 22, and 9200 (currently specified in the EC2 SG in ec2.tf).

### Security improvements
- There are a large number of possible security improvements that we can implement here, some of which I will write out.
1. Tighten the security group CIDR of the SG attached to the ElasticSearch EC2 server. There should be no reason outside of demo purposes to allow 0.0.0.0/0 traffic to port 22, and we can likely tighten the CIDR block of allowed traffic into port 9200 as well if we don't need our ElasticSearch node to be queried by the internet.

2. Move the ElasticSearch node EC2 to a private subnet. Currently it is running on a public subnet, but if ElasticSearch is only interacting with internal services/applications then there is likely no reason for it to be in a public subnet.

3. Put an ALB and attach an AWS WAF to it in front of the ElasticSearch EC2 instance. AWS WAF will let you implement a variety of rules (both custom and prewritten) to protect your deployment from various security vulnerabilities and exploits including DDOS attacks and OWASP Top 10 security risks. 
https://aws.amazon.com/waf/

4. Implement encryption. Currently interaction (ie curl requests) to this demo deployment are done via http, so it is unencrypted and can be hacked via Man in the Middle attack. We can add security certificates to this deployment via AWS Certificate Manager to create SSL/TLS certificates for our deployment. Note we will need to create a LoadBalancer in front of the EC2 since AWS Certificate Manager cannot assign certificate directly to EC2s but needs to assign it to an Load Balancer or another service (ie Cloudfront or API Gateway).
This SSL/TLS encryption will terminate at the Load Balancer level which should be fine for most use cases. But if we want to extend encryption even deeper to the EC2 or container level we will need to create a Security Certificate using an independent Public Certificate Authority inside our EC2. 

5. Implement other AWS security services to monitor our ElasticSearch EC2 node and other AWS resources, such as AWS Inspector, AWS WAF, AWS Guard Duty, etc.

### Testing
1. Format terraform code:
terraform fmt

2. Verify that terraform code is valid (Run terraform validate, and terraform plan). Will also let you see what AWS resources will get deployed and their configurations without actually deploying.
python .\elasticsearch-cli.py --status

3. Lint terraform code. Tell you if there are any invalid parameters.
tflint --init (first time only)
tflint
(Will need to do this separately from both the /module and /environments/development directories. Can add a script for this in the future.)
https://github.com/terraform-linters/tflint

4. Run Python unittests.
python -m pytest tests/test-elasticsearch-cli.py

5. Run pylint to lint Python code and make sure it is standardized.
python -m pylint *

5. Deploy in a test account. To verify that resources are deployed as you want them you can deploy in a test account and manually verify that everything is as expected.

6. *Implement testing for terraform resources using a tool like terratest https://terratest.gruntwork.io/. 

### Further Work and Potential Future Improvements
1. Setup a multi-node cluster for ElasticSearch. This would improve availability and performance of the ElasticSearch service. To do this we would need to:
    a) Expose port 9300 for node to node communication. 
    b) A Load Balancer (likely ALB) to distribute incoming web traffic evently between nodes.
    c) DNS mapping via AWS Route53 to the load balancer so network traffic is directed to it.
    d) Autoscaling for example via and AWS ASG (or k8s replicaset if we implement in kubernetes).
    e) Assigning Master, Data, and Client/Coordinating roles to our ElasticSearch cluster Nodes. Note: it is recommended to have at least 3 Master eligible nodes. Master node maintains cluster state, Data node stores data of indices, Coordinating node accepts and forwards requests to relevant Data nodes.
    f) Note if deploying a cluster make sure you set the AutoScaling group to deploy it to multi AZ for higher availability.

2. Create cron jobs for regular backups of ElasticSearch data. In the event of a disaster or if you want to restore data to a previous state you will need backups. Elasticsearch comes with a snapshot API, which you can call at regular intervals to take incremental backups of your cluster. These backups can be stored in AWS S3.

3. Setup logging in our ElasticSearch node or cluster. This can be done via Cloudwatch logs which would allow us to filter for different kinds of logs to help with troubleshooting various issues we may potentially encounter with an ElasticSearch cluster.

4. Setup monitoring and alerting. There are a variety of tools for this. We can do this via AWS Cloudwatch to setup different monitors and dashboards to keep track of things like EC2 instance health, service health checks, cpu utilization and other metrics. We can also implement a separate service such as Datadog or New Relic to keep track of additional metrics such as memory, disk usage. These services come with many integrations that we can use with a service such as PagerDuty to automatically notify stakeholders if we pass limits on certain metrics or our ElasticSearch service is unhealthy for some reason.

5. Setup cost analysis on the AWS Billing Dashboard to see how much money running our ElasticSearch node or cluster is costing us. We can add a unique tag for our AWS ElasticSearch resources so we can easily group them together in the Billing Dashboard.

6. Security. Basically everything mentioned in the Security improvements section of this doc.

7. Create our own docker file for ElasticSearch deployment instead of deploying from the base ElasticSearch image. This will give us greater customization and control of the ElasticSearch deployment. 

8. Use docker compose to deploy container(s) for more flexibility, and container orchestration. Would also make it easier to deploy an ELK stack since we could configure the container for each service in one spot if we decide to go that route in the future.

9. Deploy ElasticSearch through EKS or ECS for higher availability via pod autoscaling features, also ELK stack orchestration. Potentially implement kubernetes deployments via Helm charts.

10. Possibly setup a CI/CD pipeline to automatically run the CLI and deploy ElasticSearch and associated AWS resources to a test account. This would let us know if changes to terraform code, or the CLI would work before they go live to the CLI. This CI/CD pipeline would run all the steps mentioned Testing section of this document.

11. Have CLI run from a docker container to avoid installation requirements. The container would come with all of the prerequisites to run the CLI such as Python, terraform, etc.

12. Store terraform state in an AWS S3 bucket. Currently terraform state is stored locally. This is not conducive to a multi-developer working environment. It also runs the risk of state files getting deleted, or otherwise lost somehow. It is best to store them remotely ie in AWS S3.

13. Implement load/stress testing for our ElasticSearch deployment. This will let us see how our deployment reacts to different traffic
loads, and also collect useful metrics via our monitoring solution.

14. Add multi-stage deploy to the CLI. Currently the CLI can only deploy to one stage (environments/development). But we can add a 
parameter to the CLI code (in "elasticsearch-cli.py") to deploy to multiple stages. Then a user running the CLI can pass a stage
that they want to deploy ElasticSearch to. This stage can be a separate AWS account or region. We can add an "allowed_account_ids = [<acct_id_string>]" attribute to provider.tf to guarantee that resources do not get deployed to an incorrect stage by mistake.
ie: python .\elasticsearch-cli.py --deploy --stage=production

15. Setup autoscaling via kubernetes or AWS autoscaling groups. If done via AWS ASG make sure to use multiple AZs for higher availability. Can use ASG to monitor node status, CPU usage or other metrics and spin up additional nodes to split traffic load if needed.

16. Deploy a multi region cluster or look into CDN features so users from further regions will have lower latency and a better performance when trying to access our ElasticSearch node. Will require load balancing, CDN, or Route53 routing to direct traffic be geolocation to appropriate nodes.

17. Narrow down the AWS IAM permissions of the terraform IAM user from admin to only permissions needed to deploy ES AWS resources.

18. Currently user has to wait ~5 minutes after AWS infrastructure is spun up until they can make requests to the ElasticSearch service. This is because it takes some time for the ElasticSearch container to startup. Find if there is a way to speed this up, and also notify the user when it is completed.


### Performance Considerations
1. This is a single ElasticSearch node running on a T2 large EC2 insance. Hence it is limited in terms of CPU, memory, and disk space to the constrains of that instance. There is no WAF or other service in place to limit traffic. As such this instance is prone to being overloaded since it is not highly available, does not have protection in place against things like DDOS, and is only running on a single T2 large instance. We also do not have autoscaling or load balancing implemented if certain criteria are met ie high cpu usage, instance goes down to spin up additional instances to split the load. 

2. We are also not multi-region, and not using a CDN such as AWS CloudFront. As such, users trying to access our node from a far away region (ie Asia) will have higher latency and thus longer wait times.


### Possible Alternative Designs
1. Ansible instead of docker to deploy ElasticSearch directly on EC2. Ansible would configure the EC2 to run ElasticSearch including downloading and setting the service to run.

2. Separate code repo and CI/CD pipeline to manage ElasticSearch application image releases. ElasticSearch images and changes to the image would get pushed to ECR as part of a separate CI/CD pipeline. Then this repo can pull those images from ECR to deploy to the ElasticSearch EC2 server.

### Main Obstacles encountered while Implementing
1. I did not run into any major obstacle aside from having difficulty choosing the best design, technologies for demo purposes out of the many options that were available.

2. I was new to ElasticSearch so I had to do research on how it worked and it's features and common deploy strategies.


### Extra Features implemented
- Setup SSM agent for AWS Session Manager access. Lets you connect to the EC2 instance easier for debugging.
https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/session-manager-to-linux.html
- Added Unittests (see testing section above)
- Attached AWS infrastructure design. (ElasticSearch-Architecture-Diagram)

### Potential Deployment Issues:
- May get an error such as: "Error: creating EC2 Instance: Unsupported: Your requested instance type (t2.large) is not supported in your requested Availability Zone (us-west-2d). Please retry your request by not specifying an Availability Zone or choosing us-west-2a, us-west-2b, us-west-2c." 
This may happen because some availability zones do not have the t2.large region. To resolve this issue either specify one of the availability zones mentioned in your subnet, switch regions, or use a different type EC2 instance. 

- If elasticsearch_url is not being printed at the bottom when you run "python .\elasticsearch-cli.py --deploy". It may be because an error is blocking the complete deployment. Scroll to the top of the terraform output message to view the error
