#! /bin/bash
#sudo snap install amazon-ssm-agent --classic
sudo mount -a
sudo cp /tmp/bucket/profiles.war /var/lib/tomcat9/webapps/profiles.war && sudo chown tomcat.tomcat /var/lib/tomcat9/webapps/profiles.war
sudo systemctl start tomcat9
sudo snap start amazon-ssm-agent || true
