#! /bin/bash

start=`date +%s`

# script name and path
SCRIPT=$(readlink -f "$0")
ScriptFolder=$(dirname "$SCRIPT")
filename=$(basename -- "$SCRIPT")

if [ -z "$1" ]; then
    # Check if project is provided as an argument
	echo -e "${Bold}No project provided! Please provide the location of your Python Project as an argument after the script.${Boff}"
	exit 125
fi

if [[ ! -f $1 ]]; then
	# Check if project exists
	echo -e "${Bold}Project not found at $1 ! Directory does not exists or is not available!${Boff}"
	exit 125<
else
    ProjectFolder=$1    
fi

requirementsFile=$ProjectFolder/requirements.txt
if [[ ! -f $requirementsFile ]]; then
    # Check if requirements file exists
	echo -e "${Bold}requirements not found at $ProjectFolder ! Make sure requirements.txt exists in $ProjectFolder ${Boff}"
	exit 125
fi

if [[ ! -f Dockerfile ]]; then
    # Check if Dockerfile exists
	echo -e "${Bold}Dockerfile not found at $ScriptFolder ! Make sure Dockerfile exists in $ScriptFolder ${Boff}"
	exit 125
fi

# Build and run container
cd $ScriptFolder
docker-compose up













