# One Touch Linux and Template Setup

A JSON file is a pre-defined configuration of your Domino server.
The parameters which would need to change for each server are usually just the basic variables like the server name, organization and other basic setup options.

A common approach is to add variables into configuration files to allow to generalize configurations.

When combining the SERVERSETUP_XXX environment variable syntax with a variable/placeholder approach, the JSON file could be used as a template for setting up a server.


Example:

```"name": "{{ SERVERSETUP_SERVER_NAME }}",```

The syntax used is very similar to ([Helm Charts](https://helm.sh/) in the container world or in [Ansible](https://www.ansible.com/) automation scripts.

The variables used are the same environment variables defined for an environment variable setup.
This combines the flexibility and easy of environment variable setup with a JSON file configuration.

Here is a list of the most commonly used variables:

```
SERVERSETUP_SERVER_TYPE
SERVERSETUP_ADMIN_FIRSTNAME
SERVERSETUP_ADMIN_LASTNAME
SERVERSETUP_ADMIN_PASSWORD
SERVERSETUP_ADMIN_IDFILEPATH
SERVERSETUP_SERVER_TITLE
SERVERSETUP_SERVER_NAME
SERVERSETUP_NETWORK_HOSTNAME
SERVERSETUP_ORG_CERTIFIERPASSWORD
SERVERSETUP_SERVER_DOMAINNAME
SERVERSETUP_ORG_ORGNAME

SERVERSETUP_EXISTINGSERVER_CN
SERVERSETUP_EXISTINGSERVER_HOSTNAMEORIP
```

## Integrated functionality into the Domino Start Script and the container images

The [HCL Community Container Project](https://opensource.hcltechsw.com/domino-container/) and also the (Domino on Linux/AIX Start Script)[https://nashcom.github.io/domino-startscript/] both support the templating approach.

If a `DominoAutoConfig.json` file is found in the server data directory, the file is used to setup the server without any variable replacement.
If a `DominoAutoConfigTemplate.json` file is found in the data directory variables specified are replaced by environment variables found.

The container image also supports an automated download option for OTS template files using `SetupAutoConfigureTemplateDownload`.

You find pre-defined server configurations in the (Setup)[https://github.com/HCL-TECH-SOFTWARE/domino-one-touch-setup/tree/main/setup] directory.
