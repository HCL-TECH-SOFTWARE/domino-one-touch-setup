# Check JSON Tool

This helper tool is intended to validate Domino OneToch setup JSON files against the schema provided by Domino.
It can be used to validate a JSON file, in case  no Domino is installed on the Docker host.

To ensure compatibility with the HCL validjson, the command-line tool also supports `-default` to find the default schema file in Domino binary directory.

In addition the tool can pretty format JSON output after validation.
If you want to use it without validating JSON with the schema specify an empty string `""` or a single dot for the schema.

The program supports STDIN and STDOUT for the JSON input and output file. For STDIN/STDOUT specify a single dash.


## Syntax


```
./checkjson file.json [schema.json] [pretty.json]
```


## Examples

Validate a OTS file against the Domino OTS schema

```
checkjson /opt/nashcom/startscript/OneTouchSetup/first_server.json /opt/hcl/domino/notes/latest/linux/dominoOneTouchSetup.schema.json

JSON file [/opt/nashcom/startscript/OneTouchSetup/first_server.json] validated according to schema [/opt/hcl/domino/notes/latest/linux/dominoOneTouchSetup.schema.json]!

```

Download a JSON file via curl, pipe it via STDIN and write it pretty printed to STDOUT

```
curl -sL https://myserver.lab/software.json | ./checkjson - . -
```


## Retun codes


 Ret | Text |
| :------- | --- |
| 0 | JSON valid
| 1 | JSON invalid
| 2 | Not matching schema
| 3 | File error
| 4 | Other error

## How to build

**checkjson** is written in C++ and requires [RapidJSON](https://rapidjson.org/) and the GNU C++ compiler.


### Install GNU C++ compiler and RapidJSON development package

Ubuntu

```
apt install -y make gcc g++ rapidjson-dev
```


SUSE SLES/Leap

```
zypper install -y make gcc gcc-c++ rapidjson-devel
```

### Build binary

Switch to the `tools/checkjson` directory and run make.


```
make
```

### Install binary

This command installs the binary in /usr/bin for global use.
Note: If the binary is not build, this step will also build the binary.

```
make install
```


### Build in a Linux container

Linux has a strong requirement with glibc. The run-time environment must have at least the same version.
Therefore the following build description uses a Redhat UBI 9 container image to build the binary.


```
docker run --rm -it -v $(pwd):/local registry.access.redhat.com/ubi9:latest bash

dnf install git gcc make g++ -y

mkdir -p /local/github
cd /local/github

git clone https://github.com/HCL-TECH-SOFTWARE/domino-container.git
git clone https://github.com/Tencent/rapidjson.git

export CPLUS_INCLUDE_PATH=/local/github/rapidjson/include

cd /local/github/domino-container/tools/checkjson

make
```


### Build on Windows


Windows requires Visual Studio 2017 or higher.
In addition RapidJSON is also required to be available as header file.
The project contains a make file for Visual Studio.

To build the project on Windows use the following command line.


```
nmake -f mswin.mak 
```
