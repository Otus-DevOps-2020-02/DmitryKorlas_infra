# Homework: Lecture 5. Bastion host connection

1. oneliner to connect to the someinternalhost throught proxy host (35.210.87.16)

```bash
$ ssh -i ~/.ssh/appuser -o ProxyCommand="ssh appuser@35.210.87.16 -W %h:%p" appuser@someinternalhost
```
or
```bash
$ ssh -i ~/.ssh/appuser -A -J appuser@35.210.87.16 appuser@someinternalhost
```

2. using sshconfig

add this fragment into ~/.ssh/host
(see https://www.redhat.com/sysadmin/ssh-proxy-bastion-proxyjump)
```bash
### The Bastion Host
Host bastion
  HostName 35.210.87.16 # external IP
  User appuser
  IdentityFile ~/.ssh/appuser

### The Remote Host
Host someinternalhost
  HostName 10.132.0.3 # internal network IP
  User appuser
  ProxyJump bastion
  IdentityFile ~/.ssh/appuser
```
then, use this command to access someinternalhost
```bash
$ ssh someinternalhost
```

## Homework results:

bastion_IP = 35.210.87.16
someinternalhost_IP = 10.132.0.3


## helpful links
* https://client.pritunl.com/#features
* https://docs.mongodb.com/manual/tutorial/install-mongodb-on-ubuntu/
* [how-to-setup-a-vpn-server-using-pritunl-on-ubuntu-1804](https://www.howtoforge.com/tutorial/how-to-setup-a-vpn-server-using-pritunl-on-ubuntu-1804/?__cf_chl_captcha_tk__=25ffbbbd7a23934a7d14ca2ea94826a65ca82f46-1584902938-0-ARa5E6wAYkDV5AS7Qgmhx0qqpkl5BY0vSv4dUwPOUpemSE_dBs_pDlX5-uCfSu8c65l5AVXZ5ZlXxHjMwPa2jxEqaA-QqrnS_J3v2R_5J_BngD-ljD2v_VSHTunQr0IZfwRget3Akq1FvCWewgUPkPPEBoR8DX0sinOfgmhPYWFhbVd0aLyVhqX0t56Ed3m_MgLet8UOiyP2cDkffejELRapJkALlI6257bR7Rsk8If71WBwW1A3LgoaJUXQdPxmtjb5lS0Sv0EoqdqINMh-1T9ye1H3dR02tzPT0mR9_NhFcbblq5YvXesjXsqQtyMmKcty_BFw4_y68dOFMSDJFhLB3EvuE_QZBE5JW8ECStUU8x0A23GqSq05lGR3VHmRgqHUkeuXORJ3hzevyKugQ_MBwTJcc6mP_S5IwnpmGPY6)


# Homework: Lecture 6.
1. add firewall rule using gcloud
```google cloud
gcloud compute --project=infra-271514 \
firewall-rules create default-puma-server \
  --direction=INGRESS \
  --priority=1000 \
  --network=default \
  --action=ALLOW --rules=tcp:27017,tcp:9292 \
  --target-tags=puma-server
```
2. init app using local startup script
```google cloud
gcloud compute instances create reddit-app \
  --metadata-from-file startup-script=install-cloud-testapp.sh \
  --boot-disk-size=10GB \
  --image-family ubuntu-1604-lts \
  --image-project=ubuntu-os-cloud \
  --machine-type=f1-micro \
  --tags puma-server \
  --restart-on-failure
```
You can observer logs in this file `/var/log/syslog`

3. init app using bucket startup script

3.1. create bucket
```google cloud
gsutil mb gs://bucket-cloud-testapp
```
3.2. copy startup script from local machine to the bucket
```google cloud
gsutil cp ./install-cloud-testapp.sh gs://bucket-cloud-testapp
```

3.3. create VM instance
```google cloud
gcloud compute instances create reddit-app \
  --metadata startup-script-url=gs://bucket-cloud-testapp/install-cloud-testapp.sh \
  --boot-disk-size=10GB \
  --image-family ubuntu-1604-lts \
  --image-project=ubuntu-os-cloud \
  --machine-type=f1-micro \
  --tags puma-server \
  --restart-on-failure
```

## Homework result:
testapp_IP = 35.242.232.186
testapp_port = 9292

## helpful links
* https://codelabs.developers.google.com/codelabs/cpo200-startup-scripts/index.html
* https://medium.com/@timtech4u/deploying-a-gcp-virtual-machine-instance-with-a-startup-script-fe5431f16e66

# Homework: Lecture 7. Packer base
Create image using variables from file.
Required variables:
- project_id
- source_image_family
```shell script
packer build  -var-file=variables.json ./ubuntu16.json
```

Create an image with pre-installed reddit app
```shell script
packer build  -var-file=variables.json ./immutable.json
```

Create a VM instance using just created image "reddit-full"
```google cloud
gcloud compute instances create "my-reddit-full" \
	--image-family="reddit-full" \
	--machine-type="f1-micro" \
	--boot-disk-size="11" \
	--tags="puma-server"
```

# Homework: Lecture 8. Terraform

## the task *
> add ssh key for user appuser_web using web GUI into the project metadata. What kind of issues you're see?

1. I see a message "SSH keys must be unique. The key has been already added.". So, it's unable to use the same key for multiple users.
2. When I invoke `terraform apply` - the manually added ssh key (appuser_web) has been replaced by the values from terraform config. So, I see it's not reasonable to change VM instance settings manually (using web GUI) when it controlled by terraform. All changes will be overwritten by terraform during `terafform apply`.

## the task **
> manually add reddit-app2 as a second instance. What kind of problem in this configuration?

The problem here is verbosity of config. We should not copy paste the same configuration. Keep DRY (dont repeat yourself) principles.
So, for solving this issue, we can use `count` parameter - it's helpful for creating multiple resources.

# Homework: Lecture 9. Terraform

## helpful links
https://registry.terraform.io/modules/SweetOps/storage-bucket/google/0.3.1

## the task *
> Attempt to run prod/stage configuration at the same time (simultaneously)

```shell script
terraform apply
```
got the error in output:

*Error: Error creating Address: googleapi: Error 409: The resource 'projects/MY_PROJECT_ID/regions/europe-west1/addresses/reddit-app-ip' already exists, alreadyExists*

# Homework: Lecture 10. Ansible

## helpful links
* https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html
* https://gist.github.com/pydevops/cffbd3c694d599c6ca18342d3625af97

Ansible can run commands on multiple hosts. There are few ways to do it.
- using cli
    - ansible app -m command -a 'ls -la'
    - ansible app -m shell -a 'ls -la'
- using playbook
    - ansible-playbook clone.yml

few examples:
```shell script
# cloning the repo
ansible app -m git -a 'repo=https://github.com/express42/reddit.git dest=/home/appuser/reddit_ansible'
ansible app -m command -a 'git clone https://github.com/express42/reddit.git /home/appuser/reddit_ansible'
```
```shell script
# check service status
ansible db -m service -a name=mongod
ansible db -m systemd -a name=mongod
ansible db -m command -a 'systemctl status mongod'
```
```shell script
# run multiple commands at once
ansible app -m shell -a 'ruby -v; bundler -v'
```
```shell script
# run command on all hosts (using './inventory.yml' YAML config)
ansible all -m ping -i inventory.yml
```
```shell script
# run command using './inventory' file
ansible dbserver -m command -a uptime
```

**ansible-playbook** command return statuses. In case ansible think it change something on host it report **changed=N** in the result output. This behaviour could be adjusted using changed_when parameter. See https://docs.ansible.com/ansible/latest/user_guide/playbooks_error_handling.html#overriding-the-changed-result for further reading.

Question: run `ansible-playbook clone.yml` multiple times. Review output. Then remove the destination folder and run `ansible-playbook clone.yml` again. What's going on and why.
Answer: so, when we run the command git clone multiple times with the same params, it will return such outputs: ansible will see there are no differences, and return the
```shell script
ansible-playbook clone.yml
# appserver                  : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

ansible-playbook clone.yml
# appserver                  : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

ansible app -m command -a 'rm -rf reddit'
ansible-playbook clone.yml
# appserver                  : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```
According to the output we see that ansible does not detect the changes when git clone called multiple times.

## the task *
Add a static json file for inventory. Make sure `ansible all -m ping` works correctly.

Added `inventory.static.json`. To run it, use this command `ansible all -m ping -i inventory.static.json`.

## the task **
Implement a script for dynamic inventory
Added a script *get-puma-inventory.sh* - it will receive an ip addresses from gcloud.
To run the external script, ansible.cfg has a parameter *inventory*.

This line indicates that external script will be called.
```shell script
// ansible.cfg
inventory = ./get-puma-inventory.sh
```

so, this command is configured with the dynamic inventory.
```
ansible all -m ping
```
