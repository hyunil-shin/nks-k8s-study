#!/bin/bash

set -x

h='/c/Users/shi/Desktop/k8s/helm.exe'
k='/c/Users/shi/Desktop/k8s/kubectl'

ns=$1
echo $ns

$k create namespace ${ns}


# ingress-nginx 를 2개 설치
# https://www.reddit.com/r/kubernetes/comments/1bqmhke/two_ingressnginx_in_the_same_cluster_one_for_each/?rdt=42701

$h install ingress-nginx-${ns} ./ingress-nginx-nodeport \
--namespace ${ns} \
--set controller.ingressClassResource.name=${ns} \
--set controller.ingressClass=nginx-${ns} \
--set controller.ingressClassResource.controllerValue="k8s.io/ingress-nginx-${ns}" \
--set controller.ingressClassResource.enabled=true \
--set controller.ingressClassByName=true