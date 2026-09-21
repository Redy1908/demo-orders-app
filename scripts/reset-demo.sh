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
  kubectl apply -k "$repo_root/k8s"
  kubectl -n "$namespace" rollout status deployment/orders-api --timeout=180s
else
  kubectl apply -f "$repo_root/k8s/api-config.yaml"
fi

echo "Demo reset complete. The ConfigMap volume updates without restarting orders-api. /health should return 200; /orders should return 500 once the updated configuration reaches the pod."
