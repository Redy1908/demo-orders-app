# Demo Orders App

Small Kubernetes application used to demonstrate an agent diagnosing an
incident from a GitHub issue and repository manifests.

## Architecture

The `orders-api` service reads orders from PostgreSQL. Both workloads run in
the `demo-orders` namespace.

```text
HTTP client -> Ingress -> orders-api -> PostgreSQL
```

## Build

Build the API image where the Kubernetes node can access it:

```sh
docker build -t demo-orders-api:1.0.1 .
```

For a local k3s installation using containerd, import the image into k3s:

```sh
docker save demo-orders-api:1.0.1 -o /tmp/demo-orders-api.tar
sudo k3s ctr images import /tmp/demo-orders-api.tar
```

## Deploy

```sh
kubectl apply -k k8s
kubectl -n demo-orders get pods
```

Forward the API service for local verification:

```sh
kubectl -n demo-orders port-forward svc/orders-api 18080:80
```

Open the demo UI at [http://localhost:18080](http://localhost:18080).

The process health endpoint should respond successfully:

```sh
curl http://localhost:18080/health
```

Retrieve the sample orders:

```sh
curl http://localhost:18080/orders
```

## Reset the demo

Restore the intended broken GitOps configuration after a demo or a live cluster
change:

```sh
bash scripts/reset-demo.sh
```

This reapplies the intentionally broken API configuration while PostgreSQL
sample data is retained. The API reads this ConfigMap through a mounted volume,
so the pod and its port-forward stay alive; the updated value reaches the pod
automatically. `/health` should return `200`, while `/orders` should return
`500` until the configuration issue is fixed again.

For a complete reset, including database data, use:

```sh
bash scripts/reset-demo.sh --full
```

The complete reset deletes and recreates the `demo-orders` namespace and asks
for explicit confirmation.
