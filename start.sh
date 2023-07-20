#!/bin/bash
vagrant up 

# reload rook-ceph-operator
vagrant ssh k8s-m-1 -c "kubectl -n rook-ceph delete po -l app=rook-ceph-operator --force"