# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/xenial64"
  config.vm.synced_folder ".", "/devops-exercise"

  config.vm.provision "shell" do |s|
    s.inline = " 
        apt-get update
        apt-get install -y make jq docker.io
        curl -L https://github.com/docker/compose/releases/download/1.8.1/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
        chmod +x /usr/local/bin/docker-compose
        usermod --append -G docker ubuntu
        echo 'cd /devops-exercise/' >> .bashrc
    "
  end
end
