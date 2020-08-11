#! /bin/bash
sudo snap install amazon-ssm-agent --classic
sudo snap start amazon-ssm-agent
sudo mount -a
sudo cp /tmp/bucket/stage1-3.jar /tmp/stage1-3.jar && sudo chown ec2-user.ec2-user /tmp/stage1-3.jar
sudo su - ec2-user -c 'java -jar /tmp/stage1-3.jar &'
