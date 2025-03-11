#!/bin/bash
mkdir ./.ssh
ssh-keygen -f ./.ssh/key-mundose-pin-final -t rsa
chmod -R 777 ./.ssh