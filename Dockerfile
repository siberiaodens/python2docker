# My Site
# Version: 1.0
FROM python:3.6-alpine
# Project Files and Settings
RUN mkdir -p /app
WORKDIR /app
COPY ./project/ .
RUN pip install -r requirements.txt