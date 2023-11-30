# Domimo Setup OTS configurations

This folder contains ready to use OTS JSON files.

The JSON format contains placeholders in Helm/Ansible format, which can be filled automatically.
There are mutliple ways to consume those configurations. On Linux and the container image, the functionality to replace variables is integratated.

Example syntax for placeholders:

```"name": "{{ SERVERSETUP_SERVER_NAME }}",```

