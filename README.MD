# Mac ansible innstallation
```
brew update
brew install ansible
sudo mkdir /etc/ansible
cd /etc/ansible/
touch hosts
vi host paste eblw info
[vama]
54.169.74.93
ansible --list-host all
ansible all -m ping
ssh-keygen -t rsa
id_rsa.pub
from local machine
ssh-copy-id ipofubuntu
```

# Ubuntu Ansible installation
```
$ sudo apt-get update 
$ sudo apt-get install software-properties-common 
$ sudo apt-add-repository ppa:ansible/ansible $ sudo apt-get update 
$ sudo apt-get install ansible
```

# basic commands
```
ansible -i hosts all -m ping or ansible -i hosts all -m ping --limit host2

If you need to copy a file to multiple destinations rapidly, you can use the copy module in ansible which uses SCP. So the command and its output look like below:
ansible -i hosts all -m copy -a "src=/root/test_ansible/testfile dest=/tmp/testfile"

how to install a package via the yum module on two Centos hosts.
ansible -i hosts all -m yum -a 'name=ncdu state=present'
In the below example the same command was issued to remove the previously installed ncdu package.
ansible -i hosts all -m yum -a 'name=ncdu state=absent'
```