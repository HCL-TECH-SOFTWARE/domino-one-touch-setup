

# OTS and Docker Compose to bring up three servers

Domino One Touch Setup (OTS) can be used to bring up multiple servers at once with a complete configuration.  
The first server setup registers two additional servers and additional users.  
The first user in a Domino domain created with the standard setup code before an IDVault is in place.  
But additional users are registered after the IDVault is setup and are added to the IDVault.

Nomad Web requires users from IDVault. Therefore the first user cannot be used to login via Nomad unless uploaded later.

## Technologies involved

- Docker Compose to bring up three servers
- HCL Domino Container OTS "templating" to combine environment variable and JSON OTS
- Let's Encrypt ACME based Certificate Authority setup


## Files involved in this setup

- **.env**  
  Environment file to define variables consumed in **docker-compose.yml** 
- **docker-compose.yml**  
  Docker Compose file to define and bring up three servers
- **ots_first.json**  
  OTS for a the first server
- **ots_additional.json**  
  OTS for a the two additional servers

## Servers and User setup

The first server registrs the following servers and users.
The user ID for the first registered admin during setup is stored in the person document.
The two other users are uploaded to IDVault directly.

### Servers

- darwin
- newton
- turing

### Users

- Local Admin
- Junior Admin
- Senior Admin

## Automatically configured services by OTS in Domino 14.0

The following features are always setup when OTS is bringing up a first server:

- CertMgr (**certstore.nsf**)
- Jconsole certificates issued by a CertMgr MicroCA
- Domino CA (required by Admin Central)
- Admin Central (**admincentral.nsf**)


## Additional configuration performed by this OTS setup

- Domino IDVault
- Setup server document settings
- Enable Translog
- Set important **notes.ini** settings
- **Server configuration document** including access and authentication
- Create **connection document** to replicate names.nsf and admin4.nsf
- Create startup program document to run **certmgr** on additional servers
- Add the two new admin users to **LocalDomainAdmins**

- Create and configure **domcfg.nsf** including a modern Login Form
- Create and configure **iwaredir.nsf**
- Create a Micro CA certificate and seed an upgrade to a Let's Encrypt certificate via **ACME HTTP-01 challenge** when the server has **port 80** open and a proper DNS name defined.
- Configure **Nomad Server** to use the TLS Certificate from CertMgr/certstore.nsf


## Docker Compose

[Docker Compose](https://docs.docker.com/compose/) is a tool for defining and managing multi-container Docker applications.
It allows you to use a [YAML](https://en.wikipedia.org/wiki/YAML) file to configure your application's services, networks, and volumes.
By using Docker Compose, you can streamline the process of setting up and managing for example multiple Domino servers in a single deployment.

Docker compose used to be a separate binary. Meanwhile it can be also installed as an extension to the Docker command.
When using the integrated extension the command line changes from `docker-compose` to `docker compose`. The compose command becomes a command of the docker client binary.

**Note:** Podman provides a **podman-compose**, which has not the same level of functionality and cannot be used as a replacement for Docker Compose.
But the stand-alone **docker-compose** can be also used in combination with Podman.
It's still recommended to use Docker instead of Podman when using docker-compose.yml files.


## Configure the setup

Docker compose files are usually pre-defined by an application and use an `.env` file to define parameters defined by the **docker-compose.yml** file.  
In this example the most important parameters are defined in `.env`.  
All other parameters are added in the **docker-compose.yml** to keep the file readable.  
When adopting this example, you might want to introduce more variables to make it more customizable.

### CONTAINER_IMAGE

Defines the container image used. Usually the default **hclcom/domino:latest** should work when using the community image

### SERVERSETUP_ORG_CERTIFIERPASSWORD=domino4ever

Change the certifier/ID-Vault password when your host is exposed to the internet, even for a test environment!

### SERVERSETUP_ADMIN_PASSWORD=domino4ever

Change the password used for all admin users when your host is exposed to the internet, even for a test environment!

### SERVERSETUP_INTERNET_DOMAIN

If connected to the internet, change it to your domain.  
See details in Let's Encrypt Setup section for details.

### SERVERSETUP_ACME_ACCOUNT

Let's Encrypt ACME accounts are pre-defined in **cerstore.ntf** and are added to **certstore.nsf**.
For a first test the Staging account is recommended, because accounts might get blocked, when used in the wrong way.

Once you tested your setup, switch to the production account.

```
SERVERSETUP_ACME_ACCOUNT=LetsEncryptProduction
```

## Start the Docker Compose stack


A Docker compose stack is started from the directory where the files are located.
The directory the files are located becomes the name of the compose stack and is added to the deployment.

The following command brings up a compose stack in detached state.
This means the containers are started in background instead interactively.

The stack is configured for a lab deployment and does not use volumes to persist any data on purpose.

```
docker-compose up -d
```


## Stop the Docker Compose stack

When the compose stack is stopped, the data remains. But a `docker.compose down` will remove all containers and all data is lost on purpose.

```
docker-compose stop
```


## Nomad Web access

A Domino container image with Nomad server installed and setup,
avoids a separate client and can bring up a Nomad client in a browser on any platform including Linux or even a Raspberry PI.

The only requirement is a trusted web server certificate, because the web socket connection used by Nomad server requires a trusted certificate.
Self signed simple certificates will not work! An own CA with the root CA of the certificate imported into the browser trust store in contrast would work.

After logging into the Nomad server via **port 9443**, the client can also access the two other servers.
