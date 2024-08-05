
# OTS Helper Agent

This database provides an agent to complement the OTS Application Setup and can be invoked during OTS JSON setup.  
The functionality is triggered by Linux or Notes environment variables.  
Linux environment variables are configured for example in environment variables of a container.  
In some cases it would be more convenient to specify them instead via notes.ini variables, which are deleted once consumed.  
Notes.ini variables are configured in the OTS setup part.

## Add Server to cluster

Add a server to a cluster or create a cluster.

```
SERVERSETUP_CLUSTER_NAME=DominoLabCluster
```

## Domino Auto Update

Enable Domino 14 Auto Update functionality and assign the current server as the designated server.

```
SERVERSETUP_AUTOUPDATE_MODE=1
```

## Cross certify a safe.id

Cross certify an ID which is copied into the container at run-time.  
The Domino container image provides an environment variable to download a safe.id into the server's **notesdata** from a remote HTTPS location.  
If no path is specified, Notes data directory is assumed.

```
SERVERSETUP_ORG_CERTIFIERPASSWORD
SERVERSETUP_ORG_CERTIFIERIDFILEPATH=/local/notesdata/cert.id (default: cert.id)
SERVERSETUP_ORG_SAFEIDFILEPATH=/local/notesdata/safe.id (default: safe.id)
```

## Container Environment variables

The Domino container image supports to pass a customdata.zip file.  
The customdata.zip is automatically expanded. The content can be used in agents executed by OTS application setup.  
A ready to use **otshelper.zip** is included in this folder and can be downloaded automatically as shown below.


```
CustomNotesdataZip: https://raw.githubusercontent.com/HCL-TECH-SOFTWARE/domino-one-touch-setup/main/OneTouchAgent/otshelper.zip
```

A Notes Safe.ID can also be passed in the same way. The file is copied into the data directory of the server and can be used in an OTS setup agent.

```
SafeIDFile: https://domino.lab/safe.id
```


## How to invoke the agent during OTS Setup

The following OTS JSON application configuration can be used to invoke the agent.

```
  "appConfiguration": {
    "databases": [
      {
        "filePath": "otshelper.nsf",
        "action": "update",
        "agents": [
          {
            "name": "OneTouchSetupAgent",
            "action": ["sign", "run"]
          }
        ]
      }
    ]
  }
```
