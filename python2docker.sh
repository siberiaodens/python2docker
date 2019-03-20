#! /bin/bash

start=`date +%s`

# script name and path
SCRIPT=$(readlink -f "$0")
ScriptFolder=$(dirname "$SCRIPT")
filename=$(basename -- "$SCRIPT")

if [ -z "$1" ]; then
    # Check if project is provided as an argument
	echo -e "No project provided! Please provide the location of your Python Project as an argument after the script."
	exit 125
fi

if [[ ! -d $1 ]]; then
	# Check if project exists
	echo -e "Project not found at $1 ! Directory does not exists or is not available!"
	exit 125
else
    ProjectFolder=$1    
fi

requirementsFile=$ProjectFolder/requirements.txt
if [[ ! -f $requirementsFile ]]; then
    # Check if requirements file exists
	echo -e "requirements not found at $ProjectFolder ! Make sure requirements.txt exists in $ProjectFolder"
	exit 125
fi
Dockerfile=$ProjectFolder/Dockerfile
if [[ -f $Dockerfile ]]; then
    # Check if Dockerfile exists
	echo -e "Dockerizing $ProjectFolder based on Dockerfile provided in $Dockerfile"
else
	# Create Dockerfile
	echo -e "No Dockerfile found at $ProjectFolder. Creating Dockerfile in $ProjectFolder"
cat << EOF >$Dockerfile
FROM python:3
ENV PYTHONUNBUFFERED 1
RUN mkdir /app
WORKDIR /app
ADD $requirementsFile /app/
RUN pip install -r requirements.txt
ADD $ProjectFolder /app/
EOF
fi

DockerComposeFile=$ProjectFolder/docker-compose.yml
if [[ -f $DockerComposeFile ]]; then
    # Check if docker-compose.yml exists
	echo -e "Dockerizing $ProjectFolder based on docker-compose.yml provided in $Dockerfile"
fi


if [[ ! -d $ProjectFolder/tmp ]]; then
	# Create tmp directory
	mkdir $ProjectFolder/tmp   
fi

# Start containers
docker-compose -f $DockerComposeFile up -d >> $ProjectFolder/tmp/docker-compose-output.txt
echo -e "container \e[32mstarted"
echo

if grep -q unapplied $ProjectFolder/tmp/docker-compose-output.txt; then
    echo -e "Need to apply migrations"
	echo
	docker-compose -f $DockerComposeFile run web python manage.py migrate -d
	echo -e "migrations \e[32mapplied"
	echo
else
    echo -e "\e[32mNo migrations have to be applied"
	echo
fi
rm $ProjectFolder/tmp/docker-compose-output.txt

# Start containers
#$ProjectFolder/docker-compose up
#echo -e "container \e[32started"
#echo

echo -e "python2docker has finished with dockerizing $ProjectFolder after $((end-start)) seconds." 











