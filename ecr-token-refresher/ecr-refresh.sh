#!/bin/bash
echo $1
echo "$2"
echo $3

eksctl utils write-kubeconfig --cluster $1

TOKEN=`aws ecr get-authorization-token --output text --query 'authorizationData[].authorizationToken'`
echo "{\"auths\": {\"$2\": {\"auth\": \"${TOKEN}\"}}}" > conf.json
cat conf.json
kubectl delete secret --ignore-not-found $3
kubectl create secret generic $3 --from-file=.dockerconfigjson=conf.json --type=kubernetes.io/dockerconfigjson
kubectl delete pod -l component=image-builder