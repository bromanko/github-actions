# Github Actions Runners

This repository contains the configuration for running Github Actions runners on gray-area (my
MacMini server). 

## Build Process

The Docker image is built via a Nix flake. The image is based on NixOS and includes common tools such as Docker. 
It runs the Github Actions runner via systemd and can be configured via `docker run` environment variables. 