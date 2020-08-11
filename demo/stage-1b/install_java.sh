#! /bin/bash
#sudo snap install amazon-ssm-agent --classic
sudo mount -a
sudo cp /tmp/bucket/stage1-2.jar /tmp/stage1-2.jar && sudo chown ec2-user.ec2-user /tmp/stage1-2.jar
sudo su - ec2-user -c 'java -jar /tmp/stage1-2.jar &'
sudo snap start amazon-ssm-agent
