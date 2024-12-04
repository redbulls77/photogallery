#### Photogallery project

A simple, web-based photo gallery that allows users to view images in a slideshow format. Ideal for small businesses or personal websites seeking a lightweight and customizable solution. Built using Vagrant, Virtualbox, Saltstack, Apache, and GitHub in Windows 11 with Lenovo Ideapad Flex 5. 

<img width="950" alt="demopicture" src="https://github.com/user-attachments/assets/6a211d6b-a06b-4ade-8d89-0fa45306007e">

Instructions:

Download Vagrant and Virtualbox. Configure your Vagrantfile.

```ruby

# -*- mode: ruby -*-
# vi: set ft=ruby :
# Copyright 2019-2021 Tero Karvinen http://TeroKarvinen.com

$tscript = <<TSCRIPT
set -o verbose
apt-get update
apt-get -y install tree
echo "Done - set up test environment - https://terokarvinen.com/search/?q=vagrant"
TSCRIPT

Vagrant.configure("2") do |config|
	config.vm.synced_folder ".", "/vagrant", disabled: true
	config.vm.synced_folder "shared/", "/home/vagrant/shared", create: true
	config.vm.provision "shell", inline: $tscript
	config.vm.box = "debian/bookworm64"

	# Master -kone
	config.vm.define "master" do |master|
		master.vm.hostname = "master"
		master.vm.network "private_network", ip: "192.168.88.101"
	end

	# Minion 1: Apache webpalvelin -kone 
	config.vm.define "minion1" do |minion1|
		minion1.vm.hostname = "minion1"
		minion1.vm.network "private_network", ip: "192.168.88.102"
	end
end
```

(Karvinen. 2021)

Open up Powershell and activate the machine:

```
vagrant up
```

After a short while, your virtual computers should be running. Connect to master computer:

```
vagrant ssh master
```

Make a script to download salt-master, give it executive right and run the script: 

```
#!/bin/bash

sudo apt-get update
sudo apt install curl
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://packages.broadcom.com/artifactory/api/security/keypair/SaltProjectKey/public | sudo tee /etc/apt/keyrings/salt-archive-keyring.pgp
curl -fsSL https://github.com/saltstack/salt-install-guide/releases/latest/download/salt.sources | sudo tee /etc/apt/sources.list.d/salt.sources
sudo apt-get update
sudo apt install salt-master
sudo systemctl enable salt-master
sudo systemctl start salt-master
sudo systemctl status salt-master
````

```
nano master.sh
chmod +x master.sh
./master.sh
```

Log out of master and into minion. Do the same thing, but use salt-minion instead of salt-master.

```
exit
vagrant ssh minion1
nano minion.sh
chmod +x minion.sh
./minion.sh
```

```
#!/bin/bash

sudo apt-get update
sudo apt install -y curl
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://packages.broadcom.com/artifactory/api/security/keypair/SaltProjectKey/public | sudo tee /etc/apt/keyrings/salt-archive-keyring.pgp
curl -fsSL https://github.com/saltstack/salt-install-guide/releases/latest/download/salt.sources | sudo tee /etc/apt/sources.list.d/salt.sources
sudo apt-get update
sudo apt install -y salt-minion
sudo systemctl enable salt-minion
sudo systemctl start salt-minion
sudo systemctl status salt-minion
```

Add the master's ip to minions /etc/salt/minion -file and restart salt-minion.

```
sudoedit /etc/salt/minion
master: 192.168.88.101
sudo systemctl restart salt-minion
```

Jump back to master and check and accept minion's key.

```
sudo salt-key -L
sudo salt-key -A
```

Finally to test the connection ping the minion using:

```
sudo salt '*' test.ping
```

All is working well If you got back a response:
```
minion1:
    true
```

Then let's configure apache to host the website. Make a new directory and in there an init.sls -file.

```
sudo mkdir -p /srv/salt/apache
cd /srv/salt/apache
sudoedit init.sls
```

```
create.user:
  user.present:
    - name: jade
    - home: /home/jade

apache2:
  pkg.installed

/var/www/html:
  file.recurse:
    - source: salt://apache
    - user: jade
    - group: jade
    - file_mode: 644
    - dir_mode: 755

apache2-service:
  service.running:
    - name: apache2
    - enable: True
    - watch:
      - file: /var/www/html
```
The first part creates a user named jade with the home directory /home/jade. user.present ensures that the user exists, and if not, it will create it.

The second part install the Apache2 web server package. If the package is already installed, it ensures that it remains installed.

The thrid part ensures that the files and directories in /var/www/html are synchonized from srv/salt/apache -directory where the HTML, CSS, JSON, JS and images will be. It also sets the user and group ownership to jade and assigns permission. Files will be readable by everyone but only writable by the owner. Directories on the other hand will be readable and executable by everyone and only writable by the owner.

The last part ensures that Apache2 service is running and enable to start on boot. Watch directive ensures that if the /var/www/html directory or its contents are changed, the Apache will automatically restart to reflect the chances. 

In addition to the Salt configuration, I also added the following website files to the /srv/salt/apache directory to create the photo gallery web application. 

1. index.html
2. styles.css
3. images.json
4. script.js

Then I made a new directory called imagedownload in /srv/salt for salt state for downloading the images and in there a init.sls file.

```
create_images_directory:
  file.directory:
    - name: /var/www/html/images
    - user: jade
    - group: jade
    - mode: 755

download_image_1:
  file.managed:
    - name: /var/www/html/images/1.JPEG
    - source: https://raw.githubusercontent.com/redbulls77/kuvat/main/1.JPEG
    - skip_verify: True
    - user: jade
    - group: jade
    - mode: 644

download_image_2:
  file.managed:
    - name: /var/www/html/images/2.JPEG
    - source: https://raw.githubusercontent.com/redbulls77/kuvat/main/2.JPEG
    - skip_verify: True
    - user: jade
    - group: jade
    - mode: 644

download_image_3:
  file.managed:
    - name: /var/www/html/images/3.JPEG
    - source: https://raw.githubusercontent.com/redbulls77/kuvat/main/3.JPEG
    - skip_verify: True
    - user: jade
    - group: jade
    - mode: 644

download_image_4:
  file.managed:
    - name: /var/www/html/images/4.JPEG
    - source: https://raw.githubusercontent.com/redbulls77/kuvat/main/4.JPEG
    - skip_verify: True
    - user: jade
    - group: jade
    - mode: 644
```

First part creates the /var/www/html/images directory if it doesn't already exist. It also ensures that the directory is owned by the jade user and group, with the file permissions 755, allowing the web server to access the images.

Next states ensure that the images directory is properly set up and that the images are downloaded from my GitHub repository and placed in the correct directory. 

Last thing to do is to make a top.sls -file in the /srv/salt -directory, to which states shoul be applied to which minions. I wanted to apply the states apache and imagedownload for minion1. 


```
base:
  'minion1':
    - apache
    - imagedownload
```

To demonstrate idempotence, you can run the Salt states multiple times without causing unintended side effects or errors. Apply the states using the command:

```
salt 'minion1' state.apply
```


#### Sources:

Karvinen 2021: Two Machine Virtual Network With Debian 11 Bullseye and Vagrant. https://terokarvinen.com/2021/two-machine-virtual-network-with-debian-11-bullseye-and-vagrant/.

Malin 2024: Palvelinten hallinta -kurssi. https://github.com/redbulls77/p





