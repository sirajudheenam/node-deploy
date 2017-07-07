# node-deploy
This node-deploy is to deploy a Simple Nodejs application on nginx passenger Server.

## Pre-requisites
  * nginx with passenger module installed.

  Use [nginx-passenger](https://github.com/sirajudheenam/nginx-passenger) cookbook to install this dependent packages.

## Attributes
Some Common attributes you may wish to customize

['node-deploy']['server']['name'] = DNS_NAME

['node-deploy']['server']['ip_addr'] = IP_ADDR

['node-deploy']['app']['repo'] = <your_cool_NodeJS_app_git_repo_url>
