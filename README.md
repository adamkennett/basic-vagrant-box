# Basic vagrant box for php development
A simple vagrant box using NGINX and PHP to get a local set up for projects, with the option to install a fresh instance of Wordpress.

1. Create a directory to store the project in `mkdir example-project`
2. Move to the created directory `cd example-project`
3. Clone this repository into the directory `git clone git@github.com:adamkennett/basic-vagrant-box.git .`
4. Copy example config yaml file `box_config.example.yaml` to the same directory and rename to `box_config.yaml`
5. Edit settings to desired setup within `box_config.yaml`
6. Edit hosts file, add IP and Url, this file is located at `/etc/hosts` on a mac
7. In root of project, in this example `example-project` run `vagrant up` 

Connecting with Sql Pro

MySQL Host: 127.0.0.1
Username: root
Password: password
Database: (Whatever was set in the box_config.yaml databasename field)
Port: 3306
SSH Host: (Whatever was set in the box_config.yaml url field)
SSH User: vagrant
SSH Key: ~/.ssh/id_rsa
