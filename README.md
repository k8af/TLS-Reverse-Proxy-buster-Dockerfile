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
