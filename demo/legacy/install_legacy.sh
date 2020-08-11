#! /bin/bash
sudo snap install amazon-ssm-agent --classic || true
sudo snap start amazon-ssm-agent
sudo mount -a
sudo systemctl start apache2
sudo systemctl start tomcat9
sudo systemctl start mysql
