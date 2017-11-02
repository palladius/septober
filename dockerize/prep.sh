#!/bin/bash

# This preps docker version of this run pre-run scripts into it.

DATA=$(date +%Y%m%d-%H%M%S)
echo ## DEBUG:"
ls
pwd

echo "## PROD:"
echo This script should build whats needed to dockerize Septober..
echo "Docker version: $(cat /dockerize/VERSION)"
touch /dockerized-on-$DATA.touch
