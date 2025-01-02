#!/bin/bash

#Install Kafka
helm install --values ../Services/kafka/kafka.yaml kafka oci://registry-1.docker.io/bitnamicharts/kafka --version 30.0.4
kubectl run kafka-client --restart='Never' --image docker.io/bitnami/kafka:3.8.0-debian-12-r3  --command -- sleep infinity

# registry
kubectl apply -f ../Services/kafka/kafka-schema-registry.yaml
# BIT CONNECT
kubectl apply -f ../Services/kafka/kafka-connect.yaml
# db
kubectl apply -f ../Services/kafka/kafka-ksqldb.yaml




# RED PANDA
kubectl apply -f ../Services/kafka/redpanda.yaml
kubectl port-forward svc/redpanda 8080 &