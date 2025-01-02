#!/bin/bash

# Set up MinIO for S3-compatible object storage
helm install hive-minio \
  --set accessKey=admin \
  --set secretKey=password \
  --set persistence.size=10Gi \
  --repo https://charts.bitnami.com/bitnami \
  minio

# Wait for MinIO to be ready
kubectl wait --for=condition=available --timeout=300s deployment/hive-minio

# Apply Hive Metastore and HiveServer2 YAML files
kubectl apply -f ../Services/hive/hive-metastore.yaml
kubectl apply -f ../Services/hive/hive.yaml

#Portforward the UI
# kubectl port-forward svc/hiveserver2 10002:10002

#Connect to database using tool such as Data grip
#Run the following: 
<# drop table users;
CREATE EXTERNAL TABLE users (
    hirable BOOLEAN,
    public_repos BIGINT,
    is_suspicious BOOLEAN,
    updated_at STRING,
    id BIGINT,
    blog STRING,
    followers BIGINT,
    location STRING,
    follower_list int,
    type STRING,
    commit_list int,
    bio STRING,
    commits BIGINT,
    company STRING,
    following_list ARRAY<STRING>,
    public_gists BIGINT,
    name STRING,
    created_at STRING,
    email STRING,
    followings BIGINT,
    login STRING,
    repo_list int
)
    row format delimited
    fields terminated by ','
    location 'hdfs://namenode:9000/user';

#>