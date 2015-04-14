# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure('2') do |config|
  config.vm.provider 'virtualbox' do |vb|
    # Use VBoxManage to customize the VM. For example to change memory:
    vb.customize ['modifyvm', :id, '--memory', '1024']
    # Useful when something bad happens
    # vb.gui = true
  end

  config.vm.define :registry do |node|
    node.vm.box = 'flavio/opensuse13-2'
    node.vm.box_check_update = true
    node.vm.hostname = 'registry.test.lan'
    config.vm.network :private_network, ip: '192.168.1.2', virtualbox__intnet: true

    config.vm.provision 'shell',
      path: 'vagrant/setup_private_network',
      args:'192.168.1.2'
    node.vm.provision 'shell', path: 'vagrant/provision_registry'
    node.vm.provision 'shell', inline: 'echo 192.168.1.2 registry.test.lan >> /etc/hosts'
    node.vm.provision 'shell', inline: <<EOS
rm /etc/registry-config.yml
ln -s /vagrant/vagrant/conf/registry-config.yml /etc/registry-config.yml
systemctl restart registry
EOS
  end

  config.vm.define :portus do |node|
    node.vm.box = 'flavio/opensuse13-2'
    node.vm.box_check_update = true
    node.vm.hostname = 'portus.test.lan'
    config.vm.network :private_network, ip: '192.168.1.3', virtualbox__intnet: true

    config.vm.provision 'shell',
      path: 'vagrant/setup_private_network',
      args: '192.168.1.3'
    node.vm.provision 'shell', inline: 'echo 192.168.1.2 registry.test.lan >> /etc/hosts'
    node.vm.provision 'shell', inline: 'echo 192.168.1.3 portus.test.lan >> /etc/hosts'
    node.vm.provision 'shell', inline: <<EOS
zypper -n in gcc /
  gcc-c++ /
  libstdc++-devel /
  libxml2-devel /
  make /
  patch /
  ruby2.1-devel /
  rubygem-bundler /
  sqlite3-devel /
  zlib-devel
cd /vagrant && bundler install
EOS
  end

  config.vm.define :client do |node|
    node.vm.box = 'flavio/opensuse13-2'
    node.vm.box_check_update = true
    node.vm.hostname = 'client.test.lan'
    config.vm.network :private_network, ip: '192.168.1.4', virtualbox__intnet: true

    config.vm.provision 'shell',
      path: 'vagrant/setup_private_network',
      args: '192.168.1.4'
    node.vm.provision 'shell', path: 'vagrant/provision_client'
    node.vm.provision 'shell', inline: 'echo 192.168.1.2 registry.test.lan >> /etc/hosts'
    node.vm.provision 'shell', inline: 'echo 192.168.1.3 portus.test.lan >> /etc/hosts'
  end

end
