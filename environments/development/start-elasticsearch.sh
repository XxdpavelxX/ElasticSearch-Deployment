#!/bin/bash
sudo yum update -y
sudo amazon-linux-extras install docker -y

sudo systemctl start docker
sudo usermod -aG docker ec2-user
sudo systemctl restart docker.service

# Below command starts a container named es01. It maps Elasticsearch port 9200 and sets the discovery type
# to single-node (not cluster). It also sets security to false to avoid HTTPs requirements for demo/test purposes.
# These settings are not suited for prod deployment. Port 9200 is exposed in order to hit the Elasticsearch REST API
# Can add port 9300 in the future for a multi node cluster setup for ES to communicate between nodes.

docker run -d -it --name es01 -p 9200:9200 -e "discovery.type=single-node" -e "xpack.security.enabled=false" docker.elastic.co/elasticsearch/elasticsearch:8.12.2
