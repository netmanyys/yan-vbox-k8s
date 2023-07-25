#!/bin/bash
vagrant up 

# reload rook-ceph-operator
vagrant ssh k8s-m-1 -c "kubectl -n rook-ceph delete po -l app=rook-ceph-operator --force"
vagrant ssh k8s-m-1 -c "kubectl -n rook-ceph delete po -l app=rook-ceph-tools"

sleep 360

vagrant ssh k8s-m-1 -c "helm install myprometheus /tmp/prometheus.tar.gz"