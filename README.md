

# Domino One Touch Setup (OTS)

[Domino One Touch Setup](https://help.hcltechsw.com/domino/12.0.2/admin/inst_onetouch.html) (in short: OTS) was introduced in Domino 12.0 to simplify Domino first and additional server setup.  
OTS is of special interest when automating a Domino Container setup on [Docker](https://www.docker.com/) or [Podman](https://podman.io/) and [Kubernetes](https://kubernetes.io/). But it is also helpful for normal servers on Windows, Linux and AIX.  
For business partners OTS opens a very flexible way to include their application setup during Domino setup.

There are two different methods to setup a server:


## Environment variable setup

OTS Environment variable setup is a very easy way to setup a Domino server.
The setup provides already more setup options then the classical Domino setup including CertMgr and ID Vault configuration.  
Environment variables are read from the environment variables specified before starting the server.

Check the [OTS Environment variable setup](https://help.hcltechsw.com/domino/12.0.2/admin/inst_onetouch_preparing_sysenv.html) documentation for details.


## JSON file configuration setup

[OTS JSON file setup](https://help.hcltechsw.com/domino/12.0.2/admin/inst_onetouch_preparing_json.html) uses a JSON description of the setup with many additional options including an application configuration, which can be even used to create databases, create and update documents.


# How to invoke OTS

## Environment variable setup

To setup a server using environment variables, define all the variables and add the following variable to trigger the setup on server start.

```
SetupAutoConfigure=1
```

## JSON setup

To trigger a JSON setup specify the full path to the JSON file in the following way.

### Linux/AIX

```
/opt/hcl/domino/bin/server -autoconf /local/notesdata/setup.json
```

### Windows

```
c:\domino\bin\nserver.exe -autoconf c:\notesdata\setup.json
```


# JSON format

[JSON](https://www.json.org) is a modern standard used for REST services and many other modern applications. It is less typified than XML.

- Lotus Script supports JSON parsing and generation
- The most commonly used tool to create and parse JSON in Bash is [JQ](https://jqlang.github.io/jq/)
- For C/C++ applications a commonly tool used is [RapidJSON](https://rapidjson.org/)


# Example basic OTS JSON first server

A very basic JSON configuration contains the following sections.

- **server** defines the basic server information
- **network** defines the network configuration
- **org** organisation configuration
- **admin** admin settings
- **notesINI** notes.ini settings for the server
- **security** settings

```
{
  "serverSetup": {
    "server": {
      "type": "first",
      "name": "domino-admin-server",
      "domainName": "DominoLab",
      "title": "Domino Admin Server",
      "serverTasks": "replica,router,update,amgr,adminp,collect, nomad"
    },
    "network": {
      "hostName": "domino-admin-server.domino.lab",
      "enablePortEncryption": true,
      "enablePortCompression": true
    },
    "org": {
      "orgName": "DominoLab",
      "useExistingCertifierID": true,
      "certifierIDFilePath": "/local/notesdata/cert.id",
      "certifierPassword": "my-secure-certifier-password"
    },
    "admin": {
      "firstName": "John",
      "lastName": "Doe",
      "password": "my-secure-admin-password",
      "IDFilePath": "admin.id"
    },
    "notesINI": {
      "EVENT_POOL_SIZE": "41943040"
    },
    "security": {
      "ACL": {
        "prohibitAnonymousAccess": true,
        "addLocalDomainAdmins": true
      },
      "TLSSetup": {
        "method": "dominoMicroCA"
      }
    }
  }
}
```


# Example basic OTS JSON additional server

Additional servers can be setup in a very similar way, referencing an existing server.

Instead of **first** server the **type** is set to **additional**.
The **existingServer** section defines the server to contact during setup.


```
{
  "serverSetup": {
    "server": {
      "type": "additional",
      "name": "domino-mail-server",
      "domainName": "DominoLab",
      "title": "Domino Mail Server",
      "IDFilePath": "server.id",
      "serverTasks": "replica,router,update,amgr,adminp"
    },
    "network": {
      "hostName": "domino-mail-server.domino.lab",
      "enablePortEncryption": true,
      "enablePortCompression": true
    },
    "org": {
      "orgName": "DominoLab"
    },
    "admin": {
      "CN": "John Doe"
    },
    "existingServer": {
      "CN": "domino-admin-server",
      "hostNameOrIP": "192.168.96.1"
    },
    "notesINI": {
      "LOG_REPLICATION": "0"
    }
  }
}
```


# Domino 14 additional server setup without network connectivity

Instead of an existing server all system databases can be specified in a local directory to initialize server without network connectivity.

Specify in`sourceDatabasePath` the path to a directory containing at least the system databases required for setup.
For one-touch setup to work, the seed directory must include copies of at least these system databases from the first server.
The following files must be in the "root" of the seed directory: names.nsf, admin4.nsf, events4.nsf, and certstore.nsf.
If the first server is configured to use directory assistance, the seed directory must also include da.nsf.

Example:

```
{
  "serverSetup": {
    "server": {
      "type": "additional",
      "name": "domino-mail-server",
      "domainName": "DominoLab",
      "title": "Domino Mail Server",
      "IDFilePath": "server.id"
    },
    "network": {
      "hostName": "domino-mail-server.domino.lab"
    },
    "org": {
      "orgName": "DominoLab"
    },
    "admin": {
      "CN": "John Doe"
    },
    "existingServer": {
      "sourceDatabasePath": "/local/setup"
    }
  }
}
```


# Validate a OTS JSON file

The first step to validate the JSON file is to check if the JSON file has a valid JSON format.
In addition to this basic validation, the JSON file can be checked against the OTS schema shipped with Domino.

The JSON schema file is located in the Domino binary directory.
To validate the JSON file against the schema use the `validjson` application.

```
validjson ots.json -default
```


## Security settings & TLS Configuration

The basic security settings are the same specified during standard setup.  
Security settings also allow to specify TLS Settings for Domino CertMgr for the first server.

The automated TLS Credentials setup is only intended for first servers.
**CertMgr** and **cerstore.nsf** are the new Domino domain wide feature to manage and distribute TLS Credentials (private key, certificate chain and trusted root).

For a first server you can either use A Micro CA or import TLS Credentials.

### Create a TLS Credential using a MiroCA

Use **dominoMicroCA** to create a Domino Micro Certificate Authority and use it to create a TLS certificate  
Because MicroCA certificates are mostly used for setup, there is usually no need for a custom configuration.
But additional parameters are available including ECDSA keys.

```
    "security": {
      "ACL": {
        "prohibitAnonymousAccess": true,
        "addLocalDomainAdmins": true
      },
      "TLSSetup": {
        "method": "dominoMicroCA"
      }
    }
```

### Import a TLS Credential

Use **import** to import certificate data from a **.pem**, **.p12**, .**pfx**, or a legacy **.kyr** file.


# Application Configuration

In addition to the full featured server setup, OTS can be used to create databases and create or modify documents.

The following example elements show the basic configuration.
Details and examples are covered in a separate section.


```
{
  "appConfiguration": {
    "databases": [
      {
        "filePath": "names.nsf",
        "action": "update",
        "documents": [
          {
            "action": "update",
            "findDocument": {
              "Type": "Server",
              "ServerName": "CN=domino-lab-admin-srv/O=AutoTestLab"
            },
            "items": {
              "HTTP_HomeURL": "homepage.nsf",
              "FullAdmin": "LocalDomainAdmins",
              "CreateAccess": "LocalDomainAdmins"
            }
          },
          {
            "action": "create",
            "computeWithForm": true,
            "items": {
              "Form": "ServerConfig",
              "UseAsDefault": "1",
              "ServerName": "*"
            }
          }
        ]
      }
    ]
  }
}
```


# Database operations

The `action` determines if a database is updated or created.

- **update** perform operations on an existing database
- **create** create a new database


## Creating a database from template

Usually a new database is created from template.
The database can be also signed via adminp by the server.


```
  {
    "databases": [
      {
        "action": "create",
        "filePath": "discussion.nsf",
        "title": "Demo Discussion Database",
        "templatePath": "discussion12.ntf",
        "signUsingAdminp": true
      }
    ]
  }
```


## Modifying access control of a database (ACL)

OTS allows to modify the the ACL of a new or existing database including ACL roles and all type of ACL settings.

Example ACL for database ACL settings

```
                "ACL": {
                    "roles": [ "Admin" ],
                    "ACLEntries": [
                        {
                            "name": "Full Admin/DominoLab",
                            "level": "manager",
                            "type": "person",
                            "canCreateDocuments": true,
                            "canCreateLSOrJavaAgent": true,
                            "canCreatePersonalAgent": true,
                            "canCreatePersonalFolder": true,
                            "canCreateSharedFolder": true,
                            "canDeleteDocuments": true,
                            "canReplicateOrCopyDocuments": true,
                            "isPublicReader": true,
                            "isPublicWriter": true,
                            "roles": [ "Admin" ]
                        }
                    ]
                },
```


# Document operations

Documents can be updated or created. The `action` determines the type of operation.

- **create** A new document is created
- **update** An existing document is updated

To find an existing document usually a `findDocument` element is specified.  
Beginning with Domino 14 also search formulas are supported.


## Response documents

To create a response document specify `createResponse` instead of `create`. 
The search operation searches the existing document for which the response document is created.


## Domino 14 formula example

```
"findDocument": "Form=\"Main Topic\" & Subject=\"This is a main topic\""
```

Example document:

```
        "documents": [
          {
            "action": "update",
            "findDocument": {
              "Type": "Server",
              "ServerName": "CN=adminserver/O=DominoLab"
            },
            "computeWithForm": true,
            "items": {
              "TRANSLOG_MaxSize": 4096,
              "TRANSLOG_Path": "/local/translog",
              "TRANSLOG_Performance": "2",
              "TRANSLOG_Status": "1",
              "TRANSLOG_Style": "0"
            }
          }
        ]
```

## Document items

Document items can be created in simple way by just specifying the name and the value or by specifying specific item flags.
In most cases items are visible in the form and item flags can be just set using the `computeWithForm` action.

- Text values are resulting text items with the summary flag set
- Numeric values are resulting in number fields
- Arrays result in text lists and number ranges
- Date values are represented in  ISO-8601  format (example: "20210728dirT162308,50-04")'.


## Specifying item flags

Item flags can be also specified explicitly as the following example shows.

```
             "TestTextList": {
                "type": "text",
                "value": [
                  "Junior Admin/DominoLab",
                  "Senior Admin/DominoLab"
                ],
                "names": true,
                "readers": true,
                "authors": true,
                "protected": true,
                "sign": true,
                "encrypt": true,
                "nonSummary": false
              },
```

## Date ranges support in Domino 14


# What's new in Domino 12.0.2


Note: Starting in Domino 12.0.2, One-touch setup by default creates Java controller and Java console certificates specific for the configured host name.
Be sure to provide the fully qualified DNS host name (FQDN) to ensure that the Java console, as well as LDAP and HTTP if configured, work properly.


# What's new in Domino 14

- Certificate Authority
- Create a full-text index
- Autoregister servers with specific names
- Create response documents
- Create replicas on additional servers
- FindDocument criteria can be specified by using a formula
- An additional server can be created using files in a "seed" directory if the first server is unavailable

