# TLS-Reverse-Proxy-buster-Dockerfile
Dockerfile based on Debian Buster to create an Apache HTTPS reverse proxy for local container or services

## Intro - What we have here ? 
We will build another secure linux debian based docker image and container for a reverse proxy.
In the first Dockerfile, we was building a Foundry VTT image and container as backend service.
Now we need TLS/SSL and an isolated service container which is available via reverse proxy also as container on the same host.

----

## Project Aims
The project aim is to provide a Dockerfile to build your own debian 10 based docker image and to start a container for our Reverse Proxy. 

## Iterating workflow objects
| ID | Object | Description |
| - | - | - |
| 0 | Git Repository | create repository on github |
| 1 | Readme | Fill readme file with operating details |
| 2 | Dockerfile - Linux | assemble basic Dockerfile for debian 10 (buster) |
| 3 | Dockerfile - Apache | evaluate methods to automate deployment of latest apache 2.4 version |
| 4 | Dockerfile - Apache VHost | prepare apache virtual hosts directives for port 80 and 443 |
| 5 | Dockerfile - Apache Reverse Proxy | prepare apache functionality to reverse proxy to fvtt container |
| 6 | Dockerfile - Apache TLS/SSL | request TLS/SSL certificates and use manual option with certbot to verify domain without port 80 |
| 7 | Testing - Deployment | Build Docker Image | 
| 8 | Testing - Application | Running Docker Container with subnet options and ports |
| 9 | Testing - Application | Test available ports with and without reverse proxy |
| 10 | SSL/TLS Security | Apply TLS/SSL certificates by using certbots certificates on https |

----
## Prerequisites
All you need to start is:
- Dockerfile experience
- Docker networking experience
- debian linux experience
- debian 10 (slim) for the next docker image
- Apache 2.4 for the next docker image
- Apache Reverse proxy experience
- Apache HTTPS Setup experience
- Apache VHost experience
- LetsEncrypt / Certbot experience
- Some TCP/IP networking and firewalling experience

----
## Roadmap for Preperations for hosting system
* Login to your target linux vps host and become root (# symbol)
* Do some preperations on hosting machine
* Install docker and docker-ce.
* Download Dockerfile
* Create docker image
* Run docker container in detached. volumes and ports
* Login to your created container and start Foundry VTT as user foundry
* Check some firewall rules

---

## Preperations for hosting system (vps)
# Preperations for hosting system (vps)

### Adding repos to hosting server
If you need more software on your hosting system, add some more sources to your /etc/apt/sources.list

> #echo 'deb http://httpredir.debian.org/debian buster main non-free contrib' >> /etc/apt/sources.list
> 
> #echo 'deb-src http://httpredir.debian.org/debian buster main non-free contrib' >> /etc/apt/sources.list
> 
> #echo 'deb http://security.debian.org/debian-security buster/updates main contrib non-free' >> /etc/apt/sources.list
> 
> #echo 'deb-src http://security.debian.org/debian-security buster/updates main contrib non-free' >> /etc/apt/sources.list
> 

---

### Install docker on hosting machine
You need to do some steps before you can install docker-ce.
> #apt update
> 
> #apt install apt-transport-https ca-certificates curl gnupg2 software-properties-common
> 
> #curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
> 
> #add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
> 
> #apt update
> 
> #apt-cache policy docker-ce
> 
> #apt install docker-ce

---

### Check that docker daemon is running
> #systemctl status docker
> 
---
### Install some usefull tools
Install some packages if you need more, add some more tools.
We don't need to install any manpages on the vps.
> #apt install apt-transport-https ca-certificates curl software-properties-common
> 
> #apt update && apt upgrade
> 
> #apt install apt-file iproute2 inetutils-ping dns-utils free atop tree net-tools ufw

Try to reduce huge packages installations to minimize binary data on your host machine.

---

### Dockerfile Image & Container Setup

#### Download Dockerfile
* Change to project directory and download or clone my files from github [repository files](https://github.com/k8af/TLS-Reverse-Proxy-buster-Dockerfile).
* Change some system config details in the *Dockerfile* as you wish (hostnames, ports i.e.)
* Docker container is listening on a non TLS/SSL port 10250 (use any Port)
* We exchange data between our proxy container and the exposed port of your [Foundry VTT Container](https://github.com/k8af/fvtt-buster-Dockerfile)
* You don't need to publish ports for your foundry vtt container anymore

> wget https://github.com/k8af/TLS-Reverse-Proxy-buster-Dockerfile/edit/main/Dockerfile
> 

#### Now let's create the docker image
* We create the docker image within the directory where the *Dockerfile* exists 
* Send docker build process output to standard output and standard error, send it to files called "build_status.log" and "build_error.log"
* It tooks several minutes to download all parts from internet. (depends on your inet connection)

> #docker build -t fvtt-rproxy-deb10-slim . 1>build_status.log 2>build_error.log
> 

#### Run and start container in the background
Considering the docker volumes specification, we will use the proxy container to hide our foundry vtt host from bridge network.
If all is fine now, run an interactive container in detach mode, with volumes and with hostname "rproxy" and ip from the image we've created above
As you can see we add two hosts and one ip on this stage. We publishing our ports here only to route host requests to our proxy container.
> #docker run -itd -h rproxy -p 10250:80 --ip=172.23.3.1 --add-host=rproxy:172.23.3.1 --add-host=fvtt:172.23.3.2 --name=foundryvtt-reverse-proxy --network fvtt-net fvtt-rproxy-deb10-slim
> 

---

#### Start container manually
> #docker container start foundryvtt-server
> 

#### Stop container
> #docker container stop foundryvtt-server
>

---

#### Monitoring Docker Container Status
After you run the container, have a look at the container stats of your host in a seperate terminal with the following command:
> docker container stats
> 

---

#### Connect with container as terminal session in a bash shell
> #docker exec -it foundryvtt-server /bin/bash
>

---

Hint: You also can try out my simple shell script "container_manager.sh" to run, start, stop and login to your container.

---

#### Port Forwarding
Foundry VTT Server is listening on Port 30000 by default, thats why we exposed that port without publishing it.
Both containers should communicate on this way only.

Take a minute to think about your port forwardings.

> Foundry-VTT (30000) <--> Exposed Port (30000) <--> Proxy Container <--> VPS Provider Firewall Forwarding <--> Public Access
> 

----

### Workflow Object 5

Start at first your FOundryVTT Container then the proxy container. Check your docker host from outside to test accessability of your containers.
Evaluate your ports of the docker host to open only the proxy container port to public.

Next steps we will make are
* uploading Dockerfiles from both images to create images & container on your vps
* Operation Testing online accessability of foundryvtt gui
* Create tls/ssl keys and certificates



