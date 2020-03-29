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
