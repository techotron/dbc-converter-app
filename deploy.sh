#!/usr/bin/env bash

#Script variables
awsProfileName="intapp-devopssbx_eddy.snow@intapp.com"
awsRegion="eu-west-1"
appVersion="$(date +%F_%H%M%S)"
appPackageS3Bucket="278942993584-eddy-scratch"
appPackageS3Key="git/dbc-converter-app/app/$(echo $appVersion)_appPackage.zip"

s3StackName="dbc-converter-s3"
s3StackUrl="https://s3-eu-west-1.amazonaws.com/278942993584-eddy-scratch/git/dbc-converter-app/cfn/s3.yml"
sqsStackName="dbc-converter-sqs"
sqsStackUrl="https://s3-eu-west-1.amazonaws.com/278942993584-eddy-scratch/git/dbc-converter-app/cfn/sqs.yml"
sesRuleSetStackName="dbc-converter-sesRuleSet"
sesRuleSetStackUrl="https://s3-eu-west-1.amazonaws.com/278942993584-eddy-scratch/git/dbc-converter-app/cfn/ses-ruleset.yml"
stateMachineStackName="dbc-converter-state-machine"
stateMachineStackUrl="https://s3-eu-west-1.amazonaws.com/278942993584-eddy-scratch/git/dbc-converter-app/cfn/state-machine.yml"

# Upload CloudFormation templates to s3
aws s3 cp ./cfn/ s3://278942993584-eddy-scratch/git/dbc-converter-app/cfn --recursive --profile intapp-devopssbx_eddy.snow@intapp.com

# Package Python functions
zip -j /tmp/$(echo $appVersion)_appPackage.zip ./app/*

# Upload package to s3
aws s3 cp /tmp/$(echo $appVersion)_appPackage.zip s3://278942993584-eddy-scratch/git/dbc-converter-app/app/ --profile intapp-devopssbx_eddy.snow@intapp.com


######### Deploy CloudFormation Templates ##############################
# Deploy S3 Bucket
echo "[$(date)] - s3 stack"
if [ ! $(aws cloudformation describe-stacks --region $awsRegion --profile $awsProfileName | jq '.Stacks[].StackName' | grep $s3StackName) ]; then
    echo "[$(date)] - Creating $s3StackName stack"
    aws cloudformation create-stack --stack-name $s3StackName --template-url $s3StackUrl --profile $awsProfileName --region $awsRegion --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM;
    aws cloudformation wait stack-create-complete --stack-name $s3StackName --profile $awsProfileName --region $awsRegion
else
    echo "[$(date)] - Updating $s3StackName stack"
    aws cloudformation update-stack --stack-name $s3StackName --template-url $s3StackUrl --profile $awsProfileName --region $awsRegion --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM;
    aws cloudformation wait stack-update-complete --stack-name $s3StackName --profile $awsProfileName --region $awsRegion
fi

# Deploy SQS
echo "[$(date)] - sqs stack"
if [ ! $(aws cloudformation describe-stacks --region $awsRegion --profile $awsProfileName | jq '.Stacks[].StackName' | grep $sqsStackName) ]; then
    echo "[$(date)] - Creating $sqsStackName stack"
    aws cloudformation create-stack --stack-name $sqsStackName --template-url $sqsStackUrl --profile $awsProfileName --region $awsRegion --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM;
else
    echo "[$(date)] - Updating $sqsStackName stack"
    aws cloudformation update-stack --stack-name $sqsStackName --template-url $sqsStackUrl --profile $awsProfileName --region $awsRegion --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM;
fi

# Deploy State Machine
echo "[$(date)] - state machine stack"
if [ ! $(aws cloudformation describe-stacks --region $awsRegion --profile $awsProfileName | jq '.Stacks[].StackName' | grep $stateMachineStackName) ]; then
    echo "[$(date)] - Creating $stateMachineStackName stack"
    aws cloudformation create-stack --stack-name $stateMachineStackName --template-url $stateMachineStackUrl --parameters ParameterKey=appPackageS3Bucket,ParameterValue=$appPackageS3Bucket ParameterKey=appPackageS3Key,ParameterValue=$appPackageS3Key --profile $awsProfileName --region $awsRegion --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM;
else
    echo "[$(date)] - Updating $stateMachineStackName stack"
    aws cloudformation update-stack --stack-name $stateMachineStackName --template-url $stateMachineStackUrl --parameters ParameterKey=appPackageS3Bucket,ParameterValue=$appPackageS3Bucket ParameterKey=appPackageS3Key,ParameterValue=$appPackageS3Key --profile $awsProfileName --region $awsRegion --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM;
fi

# Deploy Ruleset
echo "[$(date)] - ses ruleset stack"
if [ ! $(aws cloudformation describe-stacks --region $awsRegion --profile $awsProfileName | jq '.Stacks[].StackName' | grep $sesRuleSetStackName) ]; then
    echo "[$(date)] - Creating $sesRuleSetStackName stack"
    aws cloudformation create-stack --stack-name $sesRuleSetStackName --template-url $sesRuleSetStackUrl --profile $awsProfileName --region $awsRegion
else
    echo "[$(date)] - Updating $sesRuleSetStackName stack"
    aws cloudformation update-stack --stack-name $sesRuleSetStackName --template-url $sesRuleSetStackUrl --profile $awsProfileName --region $awsRegion
fi


