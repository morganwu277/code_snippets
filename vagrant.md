# A Simple Vagrantfile
```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "centos/7"
  config.vm.box_check_update = false
  config.vm.network "forwarded_port", guest: 80, host: 8080
  config.vm.synced_folder ".", "/home/vagrant/project",
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "1024"
    vb.cpus = "1"
    vb.customize ["modifyvm", :id, "--cpuexecutioncap", "50"]
  end
end
```

# A moderate Example of Vagrantfile
```ruby
Vagrant.configure(2) do |config|
  config.vm.box = "project"
  '''
  the project_base.json will be something like .... 
  {
    "description": "project local box",
    "short_description": "project local box",
    "name": "project",
    "versions": [{
        "version": "0",
        "status": "active",
        "description_html": "<p>Dev Environment</p>",
        "description_markdown": "Dev Environment",
        "providers": [{
            "name": "virtualbox",
            #{ this project.box is on top of ubuntu or centos}
            "url": "https:\/\/xxx.xxx.com/project.box" 
        }]
    }]
}
  '''
  config.vm.box_url = "https://xxxx.xxx.com/project_base.json"
  config.proxy.enabled = false
  config.env.enable
  config.vm.synced_folder ".", "/home/vagrant/project",
      :nfs => true,
      :mount_options => ['rw', 'vers=3', 'tcp', 'fsc', 'actimeo=2']  # the fsc is for cachedfilesd
  config.bindfs.bind_folder '/home/vagrant/project', '/home/vagrant/project'
  config.vm.define :project do |project|
    project.vm.hostname = "project"
    
    #{ here is the shell init }
    project.vm.provision "bootstrap", type: "shell" do |s|
      s.inline = "cd /home/vagrant/project/common && ./setup-noj-local.sh"
      s.privileged = false
    end
    
    project.vm.provider "virtualbox" do |v|
      v.memory = 2048
      v.cpus = 1
      v.customize ["modifyvm", :id, "--cpuexecutioncap", "50"]
    end
    
    project.vm.network "private_network", ip: "192.168.34.10" #  reserved private address space, for nfs
    project.vm.network :forwarded_port, guest: 8000, host: 8000
    project.vm.network :forwarded_port, guest: 8002, host: 8002
    project.vm.network :forwarded_port, guest: 80, host: 80  # apache2
  end
end
```
