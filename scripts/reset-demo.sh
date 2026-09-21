#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
namespace="demo-orders"

if [[ "${1:-}" == "--full" ]]; then
  read -r -p "Delete namespace ${namespace} and its PostgreSQL data? Type reset-demo to continue: " confirmation
  if [[ "$confirmation" != "reset-demo" ]]; then
    echo "Full reset cancelled."
    exit 1
  fi

  kubectl delete namespace "$namespace"
  kubectl wait --for=delete "namespace/$namespace" --timeout=180s
fi

kubectl apply -k "$repo_root/k8s"
kubectl -n "$namespace" rollout restart deployment/orders-api
kubectl -n "$namespace" rollout status deployment/orders-api --timeout=180s

echo "Demo reset complete. /health should return 200; /orders should return 500 until the intended configuration issue is fixed."
