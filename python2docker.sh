#! /bin/bash

start=`date +%s`

# script name and path
SCRIPT=$(readlink -f "$0")
ScriptFolder=$(dirname "$SCRIPT")
filename=$(basename -- "$SCRIPT")
ProjectName=$(find $1 -maxdepth 0 -printf "%f\n")

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
ADD requirements.txt /app/
RUN pip install -r requirements.txt
ADD . /app/
EOF
fi

DockerComposeFile=$ProjectFolder/docker-compose.yml
if [[ -f $DockerComposeFile ]]; then
    # Check if docker-compose.yml exists
	echo -e "Dockerizing $ProjectFolder based on docker-compose.yml provided in $Dockerfile"
else
	# Create Dockerfile
	echo -e "No docker-compose.yml found at $ProjectFolder. Creating docker-compose.yml in $ProjectFolder"
cat << EOF >$DockerComposeFile
version: '3'
services:   
  web:
    build: .
    command: python3 manage.py runserver 0.0.0.0:8990
    volumes:
      - .:/$ProjectName
    ports:
      - "8990:8990"
    depends_on:
      - db
  db:
    image: postgres
    ports:
      - "5432:5432"
EOF
fi


if [[ ! -d $ScriptFolder/tmp ]]; then
	# Create tmp directory
	mkdir $ScriptFolder/tmp   
fi

# Start containers
docker-compose -f $DockerComposeFile up -d
echo -e "container \e[32mstarted"
echo
sleep 5
echo -e "Restarting Web Services:"
echo
docker-compose -f $DockerComposeFile restart web
sleep 5
docker-compose -f $DockerComposeFile logs --no-color --tail=1000 web > $ScriptFolder/tmp/docker-compose-output.txt

if grep -q unapplied $ScriptFolder/tmp/docker-compose-output.txt; then
    echo -e "Need to apply migrations"
	echo
	docker-compose -f $DockerComposeFile run web python manage.py migrate
	echo -e "migrations \e[32mapplied"
	echo
else
    echo -e "\e[32mNo migrations has to be applied"
	echo
fi
rm -rf $ScriptFolder/tmp

# Start containers
#$ProjectFolder/docker-compose up
#echo -e "container \e[32started"
#echo

echo -e "python2docker has finished with dockerizing $ProjectFolder after $((end-start)) seconds." 











