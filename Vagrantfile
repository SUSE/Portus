# frozen_string_literal: true

# -*- mode: ruby -*-
# vi: set ft=ruby :

# rubocop:disable Metrics/BlockLength
Vagrant.configure("2") do |config|
  config.vm.provider "virtualbox" do |vb|
    # Use VBoxManage to customize the VM. For example to change memory:
    vb.customize ["modifyvm", :id, "--memory", "1024"]
    # Useful when something bad happens
    # vb.gui = true
  end

  config.vm.define :registry do |node|
    node.vm.box = "flavio/opensuse13-2"
    node.vm.box_check_update = true
    node.vm.hostname = "registry.test.lan"
    node.vm.network :private_network, ip: "192.168.1.2", virtualbox__intnet: true
    node.vm.network :forwarded_port, host: 44_242, guest: 80

    node.vm.provision(
      "shell",
      path: "examples/development/vagrant/setup_private_network",
      args: "192.168.1.2"
    )
    node.vm.provision "shell", path: "examples/development/vagrant/provision_registry"
    node.vm.provision "shell", inline: "echo 192.168.1.2 registry.test.lan >> /etc/hosts"
    node.vm.provision "shell", inline: "echo 192.168.1.3 portus.test.lan >> /etc/hosts"
    node.vm.provision "shell", inline: <<~CERTIFICATES
      mkdir -p /etc/registry
      cp /vagrant/examples/development/vagrant/conf/ca_bundle/server.crt /etc/registry/portus.crt
      cp /vagrant/examples/development/vagrant/conf/registry-config.yml /etc/registry/config.yml
      systemctl enable registry
      systemctl restart registry
    CERTIFICATES
  end

  config.vm.define :portus do |node|
    node.vm.box = "flavio/opensuse13-2"
    node.vm.box_check_update = true
    node.vm.hostname = "portus.test.lan"
    node.vm.network :private_network, ip: "192.168.1.3", virtualbox__intnet: true
    node.vm.network "forwarded_port", guest: 80, host: 5000

    node.vm.provision(
      "shell",
      path: "examples/development/vagrant/setup_private_network",
      args: "192.168.1.3"
    )
    node.vm.provision "shell", inline: "echo 192.168.1.2 registry.test.lan >> /etc/hosts"
    node.vm.provision "shell", inline: "echo 192.168.1.3 portus.test.lan >> /etc/hosts"
    node.vm.provision "shell", inline: <<~PROVISION
      zypper -n in tcpdump

      zypper -n in apache2-devel \
        gcc \
        gcc-c++ \
        git-core \
        libcurl-devel \
        libmysqlclient-devel \
        libopenssl-devel \
        libstdc++-devel \
        libxml2-devel \
        libxslt-devel \
        make \
        mariadb \
        nodejs \
        patch \
        ruby2.1-devel \
        rubygem-bundler \
        zlib-devel

      zypper ar -f http://download.opensuse.org/repositories/devel:/openQA/openSUSE_13.2/ phantomjs
      zypper --gpg-auto-import-keys ref

      zypper -n in phantomjs

      systemctl enable mysql
      systemctl start mysql

      cd /vagrant
      bundle config build.nokogiri --use-system-libraries
      bundle install --retry=3
      bundle exec rake db:create
      bundle exec rake db:migrate
      bundle exec rake db:seed

      sudo gem install passenger -v 5.0.7
      passenger-install-apache2-module.ruby2.1 -a

      cp /vagrant/examples/development/vagrant/conf/portus/sysconfig_apache2 /etc/sysconfig/apache2
      cp /vagrant/examples/development/vagrant/conf/portus/httpd.conf.local /etc/apache2/httpd.conf.local
      cp /vagrant/examples/development/vagrant/conf/portus/portus.test.lan.conf /etc/apache2/vhosts.d/

    PROVISION

    node.vm.provision "shell", inline: <<~APACHE
      cd /vagrant
      sudo npm install webpack yarn n -g
      sudo n latest
      # Change path so that latest node binary can be used
      PATH=/usr/local/bin:$PATH
      yarn install
      # run webpack locally on the portus web VM
      webpack --watch --config config/webpack.js &

      systemctl enable apache2
      systemctl start apache2
    APACHE
  end

  config.vm.define :client do |node|
    node.vm.box = "flavio/opensuse13-2"
    node.vm.box_check_update = true
    node.vm.hostname = "client.test.lan"
    node.vm.network :private_network, ip: "192.168.1.4", virtualbox__intnet: true

    node.vm.provision(
      "shell",
      path: "examples/development/vagrant/setup_private_network",
      args: "192.168.1.4"
    )
    node.vm.provision "shell", path: "examples/development/vagrant/provision_client"
    node.vm.provision "shell", inline: "echo 192.168.1.2 registry.test.lan >> /etc/hosts"
    node.vm.provision "shell", inline: "echo 192.168.1.3 portus.test.lan >> /etc/hosts"
  end
end
# rubocop:enable Metrics/BlockLength
