# Extending One Touch Setup with Notes Agents

One Touch Setup (OTS) is primarily designed to initialize a server and configure its essential settings. HCL focuses on features required during server setup and those integrated into core Domino functionalities. For example, setting up a Domino Certificate Authority (CA), configuring CertMgr, and establishing TLS Credentials (Web server X509 certificates).


## appConfiguration

Beyond traditional setup operations for initializing a first or additional server, OTS JSON also supports creating/modifying databases, documents, running agents in databases, or signing databases. This functionality is highly flexible but requires generating extensive content in JSON format.

Signing entire databases is executed via an AdminP request, which means the operation might not complete during OTS. However, there is a flexible option to sign and run an agent synchronously during OTS setup, allowing creation of custom logic not directly possible with OTS.


### Signing and Running an Agent

To use agents during OTS, there is an inline sign operation that signs the agent on the fly using the server.id before executing it.

The following example shows a minimal appConfiguration to sign and run an agent:

```json
  "appConfiguration": {
    "databases": [
      {
        "filePath": "ots.nsf",
        "action": "update",
        "agents": [
          {
            "name": "OneTouchSetup",
            "action": ["sign", "run"]
          }
        ]
      }
    ]
  }
```


## Application Setup Agent

Although OTS can perform various functions, leveraging an agent for specific operations can be advantageous.
It often makes sense to bundle application-specific configuration within an agent.
An agent can be used from OTS and also on an existing server to avoid duplicating setup logic.
A best practice is to configure the main setup via OTS and use application-specific configuration agents as part of your application deployment.


## Admin/Root Privileged Setup Operations

Operations performed via OTS leverage the application user ("notes") and cannot execute tasks requiring Admin/root privileges.
Such additions need to be incorporated during container build.
The HCL Domino Community Container supports integrating custom installers during image build.


## Providing a CustomNotesdata.Zip

The Domino container image allows to download and extract a "**customdata.zip**", which can include an application with a setup database or agent.

The environment variable `CustomNotesdataZip` can define a zip file containing files to be extracted into the Domino Data directory. Values starting with `http` (preferably https://) are treated as URLs, and the file will be downloaded from the specified URL.

The **CustomNotesdata.Zip** is downloaded and extracted by the container entrypoint logic before OTS begins, enabling the use of the extracted databases during OTS setup.
Data provided in this way is not limited to templates or databases.
