#!/bin/bash
# This Installation will work for both Ubuntu v16.04, v18.04 and Centosv7
# Author: Alexander Hill
# Company: Exxact COrp
# Revision v1

#set -e  # exit immediately on error
set -u  # fail on undeclared variables

## Make sure to have root privilege
if [ "$(whoami)" != 'root' ]; then
  echo -e "\e[31m\xe2\x9d\x8c Please retry with root privilege.\e[m"
  exit 1
fi

# Change K8s Dashboard ClusterIP to NodePort
# kubectl edit service/kubernetes-dashboard -n kube-system
kubectl patch svc kubernetes-dashboard --type='json' -p '[{"op":"replace","path":"/spec/type","value":"NodePort"}]' -n kube-system

# Change Grafana Dashboard ClusterIP to NodePort
# kubectl edit service/grafana -n monitoring
kubectl patch svc grafana --type='json' -p '[{"op":"replace","path":"/spec/type","value":"NodePort"}]' -n monitoring
