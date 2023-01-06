#!/bin/bash

# Author: Noah Costello
# Created on: 3 JAN 2023

# The purpose of this script is to initialize Terraform 
# and AWS CLI code so that it can be run on 
# any bash environment (local, cicd, server, etc)
# to deploy AWS infrastructure

# Script will fail if any command fails when this is set
set -e

# Check if AWS PROFILE is set, else creds should be ENV VARS
if [ -n "$AWS_PROFILE" ]
then
    echo "Using AWS_PROFILE for authentication..."
elif [ -n "$AWS_ACCESS_KEY_ID" ] && [ -n "$AWS_SECRET_ACCESS_KEY" ]
then
    echo "Using AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY for authentication..."
else
    echo "No authentication methods selected, aborting..."
    exit 1
fi

echo "Running terraform validate..."
terraform validate
echo "Running terraform init..."
terraform init
echo "Running terraform apply..."
terraform apply
if [ "$GITHUB_REF_NAME" != "main" ]
then
    echo "Branch is $GIRHUB_REF_NAME. Autodestroying environment..."
    terraform destroy
fi

echo "Build completed."