#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="petclinic"
OVERLAY_PATH="$(dirname "$0")"

echo "[1/4] Deleting old namespace if it exists..."
kubectl delete namespace ${NAMESPACE} --ignore-not-found --grace-period=0 --force || true

echo "[2/4] Waiting for the old namespace to be fully removed..."
while kubectl get ns ${NAMESPACE} &>/dev/null; do
  echo "   → Waiting for namespace ${NAMESPACE} to be deleted..."
  sleep 2
done

echo "[3/4] Creating a new namespace..."
kubectl create namespace ${NAMESPACE}

echo "[4/4] Applying manifests from the EKS overlay..."
kubectl apply -k "${OVERLAY_PATH}"

echo ""
echo "=== EKS Deployment Completed Successfully ==="
echo ""
echo "To monitor pod startup progress:"
echo "   kubectl get pods -n ${NAMESPACE} -w"
echo ""
echo "Access the application at:"
echo "   https://tienphatng237.it.com"
echo "   https://admin.tienphatng237.it.com"
