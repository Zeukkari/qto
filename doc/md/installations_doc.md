#  QTO INSTALLATIONS AND CONFIGURATION GUIDE
* [1. INTRODUCTION](#1-introduction)
  * [1.1. PURPOSE](#11-purpose)
  * [1.2. DOCUMENT STATUS](#12-document-status)
  * [1.3. AUDIENCE](#13-audience)
  * [1.4. MASTER STORAGE AND STORAGE FORMAT](#14-master-storage-and-storage-format)
  * [1.5. VERSION CONTROL](#15-version-control)
  * [1.6. PROCESS](#16-process)
* [2. LOCAL DEPLOYMENT](#2-local-deployment)
  * [2.1. TARGET SETUP](#21-target-setup)
  * [2.2. PREREQUISITES](#22-prerequisites)
  * [2.3. TARGET SETUP](#23-target-setup)
  * [2.4. INSTALL VB+VAGRANT VIRTUAL MACHINE FOR A LOCAL UBUNTU HOST (OPTIONAL) ](#24-install-vb+vagrant-virtual-machine-for-a-local-ubuntu-host-(optional)-)
  * [2.5. BOOTSTRAP AND DEPLOY THE APPLICATION LOCALLY](#25-bootstrap-and-deploy-the-application-locally)
  * [2.6. PROVISION THE APPLICATION LOCALLY](#26-provision-the-application-locally)
* [3. FIRST TIME AWS DEPLOYMENT](#3-first-time-aws-deployment)
  * [3.1. AWS CENTRIC INFRASTRUCTURE AS A CODE RELATED INTRO](#31-aws-centric-infrastructure-as-a-code-related-intro)
  * [3.2. PREREQUISITES](#32-prerequisites)
    * [3.2.1. Configure the AdminEmail](#321-configure-the-adminemail)
    * [3.2.2. Create the aws instance deployment keys](#322-create-the-aws-instance-deployment-keys)
    * [3.2.3. Configure your aws credentials - aws keys](#323-configure-your-aws-credentials--aws-keys)
  * [3.3. INITIALISE THE AWS INFRASTRUCTURE](#33-initialise-the-aws-infrastructure)
  * [3.4. SET THE IP ADDRESS FOR THE HOST IN DNS ( OPTIONAL ) ](#34-set-the-ip-address-for-the-host-in-dns-(-optional-)-)
  * [3.5. ACCESS THE AWS HOST VIA SSH AND FETCH THE SOURCE CODE FROM GITHUB](#35-access-the-aws-host-via-ssh-and-fetch-the-source-code-from-github)
  * [3.6. BOOTSTRAP AND DEPLOY THE APPLICATION ON THE AWS INSTANCE](#36-bootstrap-and-deploy-the-application-on-the-aws-instance)
  * [3.7. PROVISION THE APPLICATION IN THE AWS INSTANCE IN DEV](#37-provision-the-application-in-the-aws-instance-in-dev)
  * [3.8. EDIT THE CONFIGURATION FILE AND START THE WEB SERVER](#38-edit-the-configuration-file-and-start-the-web-server)
  * [3.9. ACCESS THE QTO APPLICATION FROM THE WEB](#39-access-the-qto-application-from-the-web)
  * [3.10. CONFIGURE DNS](#310-configure-dns)
  * [3.11. PROVISION THE QTO WEB USERS](#311-provision-the-qto-web-users)
  * [3.12. CREATE THE TST PRODUCT INSTANCE](#312-create-the-tst-product-instance)
  * [3.13. PROVISION THE TST DATABASE](#313-provision-the-tst-database)
  * [3.14. FORK THE PRODUCTION INSTANCE](#314-fork-the-production-instance)
  * [3.15. PROVISION THE PRD DATABASE](#315-provision-the-prd-database)
* [4. PROVISION HTTPS ( ONLY IF DNS IS CONFIGURED )](#4-provision-https-(-only-if-dns-is-configured-))
* [5. NON-FIRST TIME AWS DEPLOYMENT](#5-non-first-time-aws-deployment)
  * [5.1. FORK THE LATEST STABLE DEV TO TST](#51-fork-the-latest-stable-dev-to-tst)
  * [5.2. GO TO YOUR PREVIOUS ENVIRONMENT](#52-go-to-your-previous-environment)
  * [5.3. CREATE THE AWS INSTANCE](#53-create-the-aws-instance)
  * [5.4. SETUP BASH & VIM](#54-setup-bash-&-vim)
  * [5.5. CLONE THE PROJECT ON THE SSH SERVER](#55-clone-the-project-on-the-ssh-server)
* [6. POTENTIAL PROBLEMS AND TROUBLESHOOTING](#6-potential-problems-and-troubleshooting)
  * [6.1. THE POSTGRES ADMIN USER PASSWORD IS WRONG](#61-the-postgres-admin-user-password-is-wrong)
  * [6.2. CANNOT LOGIN AT ALL IN THE WEB INTERFACE WITH THE ADMIN USER](#62-cannot-login-at-all-in-the-web-interface-with-the-admin-user)
  * [6.3. STRANGE PERMISSIONS ERRORS](#63-strange-permissions-errors)
  * [6.4. YOU HAVE REACHED THE HW PROVISIONING LIMITS OF YOUR AWS ACCOUNT](#64-you-have-reached-the-hw-provisioning-limits-of-your-aws-account)
  * [6.5. SOME KIND OF MISMATCH IN THE AWS](#65-some-kind-of-mismatch-in-the-aws)
  * [6.6. THE PROBLEM OCCURRED IS NOT MENTIONED HERE ???!!!](#66-the-problem-occurred-is-not-mentioned-here-)




    

## 1. INTRODUCTION


    

### 1.1. Purpose
The purpose of this document is to provide a description for the tasks and activities to be performed in order to achieve a fully operational qto application instance, such as the one running on the https://qto.fi site. 

    

### 1.2. Document status
This document is reviewed for the current qto version it is generated from. The document is updated and reviewed after each qto release.

    

### 1.3. Audience
This document is aimed for everyone, who shall, will or even would like to install  a qto application instance. Although this guide is aimed to be fully implementable via copy paste by following top to bottom, you need to have basic understanding of networking, protocols and Linux in order to complete the full installation, as your mileage will vary ...
This document might be of interest for people from architectural or even business roles to the extend to verify the claims for easy deployability states in other parts of the qto application documentation set.

    

### 1.4. Master storage and storage format
The master storage of this document is the master branch of the latest qto release. The main storage format is Markdown. 

    

### 1.5. Version control
The contents of this document ARE updated according to the EXISTING features, functionalities and capabilities of the qto version, in which this document residues. Thus the git commit hash of a release qto version contains the md format of this document.

    

### 1.6. Process
The qto provides a mean for tracking of this documentation contents to the source code per feature/functionality, thus should you find inconsistencies in the behaviour of the application and the content of this document you should create a bug issue and assign it to the owner of your product instance.

    

## 2. LOCAL DEPLOYMENT
You could easily skip the whole local deployment by exporting the qto ami image into a virtual box or VMWare vm from the qto ami image by using the following instructions: 
https://aws.amazon.com/ec2/vm-import/


    

### 2.1. Target setup
You could easily skip the whole local deployment by exporting the qto ami image into a virtual box or VMWare vm from the qto ami image by using the following instructions: 
https://aws.amazon.com/ec2/vm-import/


    

### 2.2. Prerequisites
You need hardware, which is powerful enough to run a virtual machine with at least 1GB of RAM ( preferably 2 or more ) and at least 20GB of hard disk space. 

    

### 2.3. Target setup
The target setup is a system comprised of dev, tst, qas and prd instances of qto locally and dev, tst , qas and prd instances in aws. 
The following diagram illustrates that setup. Naturally you will be deploying only the dev.&lt;&lt;site&gt;&gt;.com when doing the installation for first time - in the spirit of qto - you will be moving fast and destroying in dev, re-inforcing skills in tst and do it at once in prd ...


Figure 1: 
The target setup for the qto appliction
![Figure 1: 
The target setup for the qto appliction](https://github.com/YordanGeorgiev/qto/blob/master/doc/img/system_guide/qto-infra.jpg?raw=true)

    

### 2.4. Install VB+vagrant virtual machine for a local Ubuntu host (optional) 
If your physical host OS is not the Ubuntu 18.04 OS, you could Install the latest version of the OracleVirtualBox with guest additions and HashiCorp Vagrant and run the up.sh bootstrapper script on the host to get the fully provisioned guest with all the binaries and configurations. This step might take at least 30 min depending on the hardware of your host machine and the VirtualBox configurations in your setup ...

     # in the shell of your OS bash shell of your host machine
    mkdir -p ~/opt; cd $_ ; git clone https://github.com/YordanGeorgiev/qto.git ; cd ~/opt/qto
    
    # run the vagrant provisioning script
    ./src/bash/up.sh
    
    # now go to the vagrant guest
    vagrant ssh
    
    # go to the qto project in the 
    cd /home/vagrant/opt/qto/

### 2.5. Bootstrap and deploy the application locally
This step might not be needed if you used the up.sh vagrant provisioning script as described above, yet should the vagrant provisioning have failed you could run it on the vagrant guest once again and it WILL NOT if you have proper network connectivity and read/write access to your host file system from the guest.
The bootstrap script will deploy ALL the required Ubuntu 18.04 binaries AND perl modules as well as perform the needed configurations to enable the creation and load of the qto database. This step will take 20 min at least. The bootstrapping script will :
  - install all the required binaries
  - install all the required perl modules as non-root
  - install and provision postgres
  - install and provision the nginx proxy server 


 Check the main method in the run.sh and uncomment entities you do not want to install locally, should you have any ...




    # in the shell of your local Ubuntu box, skip this cmd if you are on vagrant ...
    mkdir -p ~/opt; cd $_ ; git clone https://github.com/YordanGeorgiev/qto.git ; cd ~/opt
    
    # run the bootstrap script and IMPORTANT !!! reload the bash env
    ./qto/src/bash/deployer/run.sh ; bash ; 
    

### 2.6. Provision the application locally
The run of the following "shell actions" will create the qto database and load it with a snapshot of it's data from a sql dump stored in s3. If you start getting a lot of perl "cannot not find module" syntax check error, you probably did not reload the bash shell , by just typing "bash" and hitting enter in the previous step.

     # go to the product instance dir 
    source $(find . -name '.env') && cd qto/qto.$VERSION.$ENV_TYPE.$USER
    
    # ensure application layer consistency, run db ddl's and load data from s3
    ./src/bash/qto/qto.sh -a check-perl-syntax -a scramble-confs -a provision-db-admin -a run-qto-db-ddl -a load-db-data-from-s3

## 3. FIRST TIME AWS DEPLOYMENT
This section WILL provide you will with ALL required steps to get a fully functional instance of the qto application in aws in about 35 min with automated shell commands. Do just copy paste the commands into your shell. Do NOT cd into different directories - this deployment has been tested more than 30 times successfully by exactly reproducing those steps, yet the variables in such a complex deployment are many, thus should you encounter new issues do directly contact the owner of the instance you got this deployment package from, that is the person owning the GitHub repository you fetched the source code from.

    

### 3.1. AWS centric infrastructure as a code related intro

This installation is not truly idempotent, meaning that not all infra resources with the same names are deleted - you might need to go and manually delete objects from the AWS admin console, IF you are running this installation for more than 2 times on the same environments. If you are using the same AWS account for all your environments - that is dev, tst and prd - you can be sure that this installation has been tested for FULL logical and physical separation of your provisioned qto resources by environment - simply said whatever you deploy to dev, will not brake anything in tst and/or prod.

    

### 3.2. Prerequisites
You should have a local instance of qto as far as you could issue the terraform shell action ( that is db and site configuration are not must have for the aws deployment to succeed).

    

#### 3.2.1. Configure the AdminEmail
The AdminEmail value stored in the cnf/env/*.env.json files is the e-mail of the qto product instance owner - aka the only user being able to edit other users' details.
The bootstrapping script simply replaces the demo "test.user@gmail.com" with the password "secret" with the value you will set in the AdminEmail, thus once you have authentication use the "secret" password to login in and edit users.

    

#### 3.2.2. Create the aws instance deployment keys
You will use those deployment keys later on when you later on ssh -i &lt;&lt;full-deployment-key&gt;&gt; ubuntu@&lt;&lt;instance-dns&gt;&gt;

    # create the dev instance deployment key
    # of course you should use your own e-mail and mine ;o)
    ssh-keygen -t rsa -b 4096 -C "yordan.georgiev@gmail.com" -f ~/.ssh/id_rsa.dev.qto
    # hit enter twice if you do not want to set up passwords .. 
    
    # create the tst instance deployment key
    ssh-keygen -t rsa -b 4096 -C "yordan.georgiev@gmail.com" -f ~/.ssh/id_rsa.tst.qto
    
    # create the prd instance deployment key
    ssh-keygen -t rsa -b 4096 -C "yordan.georgiev@gmail.com" -f ~/.ssh/id_rsa.prd.qto

#### 3.2.3. Configure your aws credentials - aws keys
Generate NEW aws access- and secret-keys https://console.aws.amazon.com/iam/home?region=&lt;&lt;YOUR-AWS-REGION&gt;&gt;#/security_credentials. 
Store the keys in the qto's development environment configuration file - the cnf/env/dev.env.json file.


    

### 3.3. Initialise the aws infrastructure
To initialise the git aws infrastructure you need to clone the qto source code locally first. If you are repeating this task all over you might need to remove from the aws web ui  duplicating VPC's and elastic IP's.

    # apply the infra terraform in the src/terraform/tpl/qto/main.tf.tpl 
    clear ; bash ~/opt/qto/src/bash/qto/qto.sh -a init-aws-instance

### 3.4. Set the ip address for the host in DNS ( optional ) 
If you have registered your own DNS name you should configure now the public ip address found in the amamazon ec2 instances section of the newly created host to the dns name you have registered with your DNS provider, as it usually takes some time for the DNS to replicate ( with the qto.fi domain it takes about 5 min max, some DNS providers suggest even hours to be reserved, your mileage might vary...).
If you do not have a registered DNS, you could either use directly the ip address or the dns name provided by amazon in the ec2 settings of the newly created host, in this case you should configure the same DNS in the cnf/etc/dev.env.json file ( env-&gt;app-&gt;web_host variable ) for ngix to be able to pick it in its own configuration.

    

### 3.5. Access the aws host via ssh and fetch the source code from GitHub
To access the aws host via ssh you need to copy the provided elastic ip which was created by the terraform script. In your browser go to the following url:
https://eu-west-1.console.aws.amazon.com/ec2/v2/home?region=&lt;&lt;YOUR-AWS-REGION&gt;&gt;#Instances:sort=instanceId
You should see a listing of your aws instances one of which should be named dev-qto-ec2 ( that is the development instance of the qto application). Click on it's checkbox. Search for the "IPv4 Public IP" string and copy the value of the ip.

    # run locally 
    ssh -i ~/.ssh/id_rsa.dev.qto ubuntu@<<just-copied-IPv4-Public-IP>>
    
    # on the aws server
    mkdir -p ~/opt; cd $_ ; git clone https://github.com/YordanGeorgiev/qto.git ; cd ~/opt

### 3.6. Bootstrap and deploy the application on the aws instance
The bootstrap script will deploy ALL the required Ubuntu 18.04 binaries AND perl modules as well as perform the needed configurations to enable the creation and load of the qto database. This step will take at least 20 min. The bootstrap script will perform the following actions:
 - install all the required binaries
 - install all the required perl modules as non-root
 - install and provision postgres
 - install and provision the nginx proxy server

Copy paste the full command bellow - this is IMPORTANT !!!

    # run the bootstrap script and IMPORTANT !!! reload the bash shell 
    bash ./qto/src/bash/deployer/run.sh ; bash ; 

### 3.7. Provision the application in the aws instance in dev
The run of the following "shell actions" will create the qto database and load it with a snapshot of it's data from a sql dump stored in s3. 

     # go to the product instance dir 
    source $(find . -name '.env') && cd qto/qto.$VERSION.$ENV_TYPE.$USER
    
    # ensure application layer consistency, run db ddl's and load data from s3
    bash ./src/bash/qto/qto.sh -a check-perl-syntax -a scramble-confs -a provision-db-admin -a run-qto-db-ddl -a load-db-data-from-s3

### 3.8. Edit the configuration file and start the web server
You would have to set the web_host variable in the configuration files to the ip address or DNS name if you have configured one for this ip address, otherwise your nginx configuration will be broken ...
The following command will both start the Mojolicious hyphotoad server initiating the qto application layer and the nginx reverse proxy, which will listen on the app-&gt;port port defined in the cnf/env/dev.env.json file.

    # start the web server
    ./src/bash/qto/qto.sh -a mojo-hypnotoad-start

### 3.9. Access the qto application from the web
The qto web application is available at the following address
http://&lt;&lt;just-copied-IPv4-Public-IP&gt;&gt;:8078 should redirect you to the dev_qto/login page - this is the end-point via mojolicious over http ( NOT safe ).

The qto web application is available at the following address
http://&lt;&lt;just-copied-IPv4-Public-IP&gt;&gt;:78 should redirect you to the dev_qto/login page - via the nginx proxy ( SAFE )


    

### 3.10. Configure DNS
Configure the DNS server name in the UI of your DNS provider.

    

### 3.11. Provision the qto web users
Open the cnf/env/dev.env.json, change the env-&gt;AdminEmail with an e-mail you have access to. Restart the web servers as shown bellow. Login via the 

    # the start action performs restart as well, if the web servers are running
    ./src/bash/qto/qto.sh -a mojo-hypnotoad-start

### 3.12. Create the tst product instance
If you re-visit the target architecture picture(@installations_doc-10), the actions so far have been only the installations of the dev instance - which you should have be now up and running. 
Qto is design around the idea of developing in dev ( aka doing things for first time and possibly with some errors ), testing in tst ( more of a testing and configuration allowed, but not developing with minor errors and prd ( where no errors are allowed and everything should go smoothly ). 
Thus by now you have achieved only the dev instance deployment

    ./src/bash/qto/qto.sh -a to-env=tst

### 3.13. Provision the tst database
If you re-visit the target architecture picture( installations_doc-10), the actions so far have been only the installations of the dev instance - which you should have be now up and running. 
Qto is design around the idea of developing in dev ( aka doing things for first time and possibly with some errors ), testing in tst ( more of a testing and configuration allowed, but not developing with minor errors and prd ( where no errors are allowed and everything should go smoothly ). 
Thus by now you have achieved only the dev instance deployment

    

### 3.14. Fork the production instance
The creation of this one should succeed at once, as it is perform exactly in the same way as the creation of the testing ( tst ) instance.
You "fork" the production instance by issuing the following command:

    # for the tst product instance into the prd product instance
    ./src/bash/qto/qto.sh -a to-env=prd
    
    # thus the 
    find ~/opt/csitea/qto/ -type d -mindepth 1 -maxdepth 
    
    /home/ubuntu/opt/csitea/qto/qto.0.7.8.dev.ysg
    /home/ubuntu/opt/csitea/qto/qto.0.7.8.tst.ysg
    /home/ubuntu/opt/csitea/qto/qto.0.7.8.prd.ysg

### 3.15. Provision the prd database
The creation of this one should succeed at once, as it is perform exactly in the same way as the creation of the testing ( tst ) instance.
You "fork" the production instance by issuing the following command:

    ./src/bash/qto/qto.sh -a check-perl-syntax -a scramble-confs -a provision-db-admin -a run-qto-db-ddl -a load-db-data-from-s3

## 4. PROVISION HTTPS ( ONLY IF DNS is configured )
This section is separated as it is optional. If you have configured DNS you could provision https for the nginx server by issuing the following command:


    ./src/bash/qto/qto.sh -a provision-https
    
    sudo certbot --nginx -d <<your.organisation.com>>
    
    
    # you should get the following output ... 
    #IMPORTANT NOTES:
    # - Unable to install the certificate
    # - Congratulations! Your certificate and chain have been saved at:
    #  /etc/letsencrypt/live/qto.fi/fullchain.pem
    #   Your key file has been saved at:
    
    # now re-run the 
    bash src/bash/qto/qto.sh -a provision-nginx -a provision-https
    
    
    

## 5. NON-FIRST TIME AWS DEPLOYMENT
This section is aimed for the fortuned folks, who have already deployed at least one fully functional up-and-running instance of qto, thus it will assume already some familiarity. 

    

### 5.1. Fork the latest stable dev to tst
By this point all obvious bugs within the scope of THIS release MUST be cleared out, if that is NOT the case you are wasting your time by gaining wrong velocity to demonstrate some new cool features, which you WILL pay later.

    # on your local dev box go the latest stable environment
    /hos/opt/csitea/qto/qto.0.7.9.dev.ysg
    
    bash src/bash/qto/qto.sh -a to-env=tst
    
    # now prepare the configuration in this environment on your local dev box
    cp -r /hos/opt/csitea/qto/qto.0.7.9.tst.ysg /hos/opt/csitea/qto/qto.0.7.9.tst.deploy
    
    # ensure you copy your non-hash and SECRET configuration to this instance
    cp -v ~/.qto/cnf/* cnf/env/

### 5.2. Go to your previous environment
Go to your old environment - it contains your configuration at least you could spare yourself for copy paste for the creating of the RIGHT configuration for your ENTIRELY new deployment built with the infrastructure as a code .
Open the admin console:

    ssh -i /home/ysg/.ssh/id_rsa.prd.qto  ubuntu@ec2-52-209-247-245.eu-west-1.compute.amazonaws.com

### 5.3. Create the AWS instance


    bash src/bash/qto/qto.sh -a init-aws-instance
    
    # after that ssh to -it
    ssh -i ~/.ssh/id_rsa.prd.qto ubuntu@ec2-52-209-247-245.eu-west-1.compute.amazonaws.com

### 5.4. Setup bash & vim
This deployment script sets RATHER personal bash and tmux settings ... which are NOT part of the qto setup, but merely personal tools to navigate more easily in the terminal with bash, tmux and vim ...

    curl https://raw.githubusercontent.com/YordanGeorgiev/ysg-confs/master/src/bash/deployer/setup-bash-n-vim.sh | bash -s yordan.georgiev@gmail.com
    
    cat ~/

### 5.5. Clone the project on the ssh server
Clone as follows

    cat ~/.ssh/
    
    mkdir -p ~/opt; cd $_ ; git clone git@github.com:YordanGeorgiev/qto.git; cd ~/opt

## 6. POTENTIAL PROBLEMS AND TROUBLESHOOTING
As a rule of thumb - whatever errors you are encountering they are most probably NOT source code errors, but configuration errors. Thus ALWAYS try to change configuration entries from the dev, tst or prd environment configuration files and restart the web server with the mojo-hypnotoad-start shell action.

    

### 6.1. The postgres admin user password is wrong
Basically the db security is passed from OS root to postgres user to qto admin to qto app, thus to fix it issue the following command, which will basically re-provision your postgres.
You would need to also restart the web server after executing this command.

     ./src/bash/qto/qto.sh -a provision-db-admin -a run-qto-db-ddl -a load-db-data-from-s3

### 6.2. Cannot login at all in the web interface with the admin user
The password hashing in the users table is activated ALWAYS on blur even that the ui is not showing it ( yes , that is more of a bug, than a feature.
The solution is to restart the application layer WITHOUT any authentication, change the admin user password from the ui and restart the application layer with authentication once again.

    export QTO_NO_AUTH=1
    bash src/bash/qto/qto.sh -a mojo-hypnotoad-start
    
    # now change the AdminEmail user password from the UI , delete the test users ...
    # as they all have the convinient "secret" password .. 
    export QTO_NO_AUTH=0
    bash src/bash/qto/qto.sh -a mojo-hypnotoad-start
    

### 6.3. Strange permissions errors
Some of the newly created tables might not have explicitly their permissions in the DDLs. Or you might have run some of the sql scripts ad-hoc / manually and they do not contain grant statements. Run the following one-liner:

    bash src/bash/qto/qto.sh -a provision-db-admin

### 6.4. You have reached the hw provisioning limits of your AWS account
If you get one of the errors bellow you would have to go the UI of the AWS admin console and delete non-used resources. Fortunately, all resources have the &lt;&lt;env&gt;&gt;_&lt;&lt;resource_name&gt;&gt; naming convention either in the object or in their Tags, which means that you will know what you are deleting.

    Error: Error creating VPC: VpcLimitExceeded: The maximum number of VPCs has been reached.
            status code: 400, request id: 06dbd26c-d7b2-46e1-853f-a9131c6ad9bd
    
      on main.tf line 41, in resource "aws_vpc" "tst-vpc":
      41: resource "aws_vpc" "tst-vpc" {
    
    # another one might be elastic ip's limits
    Error: Error creating EIP: AddressLimitExceeded: The maximum number of addresses has been reached.
            status code: 400, request id: 079d1264-8d2a-4dd3-9251-354634beda5c
    
      on main.tf line 203, in resource "aws_eip" "tst-ip-test":
     203: resource "aws_eip" "tst-ip-test" {

### 6.5. Some kind of mismatch in the aws
The aws web ui contains fancy ajax calls and in our experience it does not always update properly, if are bombarding it with terraform deployments onto the same resources. Make sure you hit F5 in your browser always when starting the work on new ec2 instance.

    

### 6.6. The problem occurred is not mentioned here ???!!!
Of course you quick Google it first ... if it took too long just send a e-mail / chat to the instance owner you got the source code from and you WILL get help sooner or later.

    

