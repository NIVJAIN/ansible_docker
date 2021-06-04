# Mac ansible innstallation
```
brew update
brew install ansible
sudo mkdir /etc/ansible
cd /etc/ansible/
touch hosts
vi host paste eblw info
#hosts file start#
    [vama:vars]
    ansible_ssh_private_key_file=./vamakp.pem
    [vama]
    54.xx.69.x4.9x
#hosts file ends#
ansible --list-host all
ansible all -m ping
step1 or step2
step1
ssh-keygen -t rsa
id_rsa.pub
from local machine
ssh-copy-id ipofubuntu

step2
 more ~/.ssh/id_rsa.pub
 copy the contect to ubuntu under ~/.ssh/authorized_keys
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

# Run via playbook
ansible-playbook -i ~/hosts 4-ubuntu-nginx.yaml


## Only  local host
For some reason, I don’t want to run this playbook on any of remote hosts yet. I want to test it locally and run it locally.  What should I do?

All you should do is this

ansible-playbook \
--connection=local \ 
--inventory 127.0.0.1, \
--limit 127.0.0.1 Ansible-Local.yml -i ansible_hosts


## List all hosts
ansible all --list-hosts -i ansible_hosts   [ansible_hosts is the file in the directory]
ansible all --list-hosts  [hosts file could be in /etc/ansible/hosts]