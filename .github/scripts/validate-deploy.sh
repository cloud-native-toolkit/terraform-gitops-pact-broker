#!/usr/bin/env bash

GIT_REPO=$(cat git_repo)
GIT_TOKEN=$(cat git_token)

export KUBECONFIG=$(cat .kubeconfig)
NAMESPACE=$(cat .namespace)
BRANCH="main"
SERVER_NAME="default"
NAME="pact-broker"

mkdir -p .testrepo

git clone https://${GIT_TOKEN}@${GIT_REPO} .testrepo

cd .testrepo || exit 1

find . -name "*"

if [[ ! -f "argocd/2-services/cluster/${SERVER_NAME}/base/${NAMESPACE}-${NAME}.yaml" ]]; then
  echo "ArgoCD config missing - argocd/2-services/cluster/${SERVER_NAME}/base/${NAMESPACE}-${NAME}.yaml"
  exit 1
fi

echo "Printing argocd/2-services/cluster/${SERVER_NAME}/base/${NAMESPACE}-${NAME}.yaml"
cat "argocd/2-services/cluster/${SERVER_NAME}/base/${NAMESPACE}-${NAME}.yaml"

if [[ ! -f "payload/2-services/namespace/${NAMESPACE}/${NAME}/values-${SERVER_NAME}.yaml" ]]; then
  echo "Application values not found - payload/2-services/namespace/${NAMESPACE}/${NAME}/values-${SERVER_NAME}.yaml"
  exit 1
fi

echo "Printing payload/2-services/namespace/${NAMESPACE}/pact-broker/values-${SERVER_NAME}.yaml"
cat "payload/2-services/namespace/${NAMESPACE}/${NAME}/values-${SERVER_NAME}.yaml"

count=0
until kubectl get namespace "${NAMESPACE}" 1> /dev/null 2> /dev/null || [[ $count -eq 20 ]]; do
  echo "Waiting for namespace: ${NAMESPACE}"
  count=$((count + 1))
  sleep 15
done

if [[ $count -eq 20 ]]; then
  echo "Timed out waiting for namespace: ${NAMESPACE}"
  exit 1
else
  echo "Found namespace: ${NAMESPACE}. Sleeping for 30 seconds to wait for everything to settle down"
  sleep 30
fi

DEPLOYMENT="pact-broker-${BRANCH}"
count=0
until kubectl get deployment "${DEPLOYMENT}" -n "${NAMESPACE}" || [[ $count -eq 20 ]]; do
  echo "Waiting for deployment/${DEPLOYMENT} in ${NAMESPACE}"
  count=$((count + 1))
  sleep 15
done

if [[ $count -eq 20 ]]; then
  echo "Timed out waiting for deployment/${DEPLOYMENT} in ${NAMESPACE}"
  kubectl get all -n "${NAMESPACE}"
  exit 1
fi

kubectl rollout status "deployment/${DEPLOYMENT}" -n "${NAMESPACE}" || exit 1

cd ..
rm -rf .testrepo
