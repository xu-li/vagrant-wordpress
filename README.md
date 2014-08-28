# vagrant-wordpress

A vagrant script to provision wordpress environment

## Softwares

1. [Vagrant](https://www.vagrantup.com/)
2. [virtualbox](https://www.virtualbox.org)

## Usage

### Provision a local environment using latest wordpress

1. ```git clone https://github.com/xu-li/vagrant-wordpress.git```
2. ```cd vagrant-wordpress```
3. ```vagrant up```
4. add ```192.168.10.10 wp.local``` to [hosts](http://en.wikipedia.org/wiki/Hosts_(file))
5. visit http://wp.local

### Provision a local environment using legacy wordpress

1. ```git clone https://github.com/xu-li/vagrant-wordpress.git```
2. ```cd vagrant-wordpress```
3. change ```WP_VERSION``` to the version you want to install, e.g. ```WP_VERSION="3.9.1"```
4. ```vagrant up```
5. add ```192.168.10.10 391.wp.local``` to [hosts](http://en.wikipedia.org/wiki/Hosts_(file))
6. visit http://391.wp.local

## FAQ

### Is it possible to run multiple versions of wordpress on a single box?

Yes, you can simply change the version in ```provision.sh```, and run ```vagrant reload --provision```. Don't forget to add the server name to [hosts](http://en.wikipedia.org/wiki/Hosts_(file)).
