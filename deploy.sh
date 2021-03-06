#! /bin/bash

SHA1=$1
#EB_BUCKET=elasticbeanstalk-us-west-2-489284558735
EB_BUCKET=elasticbeanstalk-oregon-us-west-2

# Deploy image to Docker Hub
#docker push circleci/hello:$SHA1
docker push 7kingdoms/hello:$SHA1

## Create new Elastic Beanstalk version
DOCKERRUN_FILE=$SHA1-Dockerrun.aws.json
sed "s/<TAG>/$SHA1/" < Dockerrun.aws.json.template > $DOCKERRUN_FILE
aws configure set default.region us-west-2
#aws configure set default.output json

aws s3 cp $DOCKERRUN_FILE s3://$EB_BUCKET/$DOCKERRUN_FILE
aws elasticbeanstalk create-application-version --application-name hello \
    --version-label $SHA1 --source-bundle S3Bucket=$EB_BUCKET,S3Key=$DOCKERRUN_FILE

# Update Elastic Beanstalk environment to new version
aws elasticbeanstalk update-environment --environment-name hello-env --version-label $SHA1
