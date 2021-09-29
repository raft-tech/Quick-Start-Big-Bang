#!/bin/bash
set -e

# This will create a kind (https://kind.sigs.k8s.io) cluster for the bigbang quick start

APPLICATION=big-bang-quick-start
IMAGE_CACHE=$(pwd)/.dod-platform-one-big-bang-cache

cluster_config_file="auto.kind.cluster.yaml"

# Clean slate
kind delete cluster --name "${APPLICATION}"


# Cluster config file for kind
# The first `extraMount` may be unnecessary on non-luks encrypted linux systems.
# Port 8080 is exposed for HTTP
# Port 8443 is exposed for HTTPS
cat << EOF > $cluster_config_file
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
    extraPortMappings:
      - containerPort: 32001
        hostPort: 8080
        protocol: TCP
      - containerPort: 32002
        hostPort: 8443
        protocol: TCP
    extraMounts:
      - hostPath: /dev/dm-0
        containerPath: /dev/dm-0
        propagation: HostToContainer
      - hostPath: ${IMAGE_CACHE}
        containerPath: /var/lib/rancher/k3s/agent/containerd/io.containerd.content.v1.content
        propagation: HostToContainer
EOF

echo "Ensuring Image Cache -- ${IMAGE_CACHE}"
mkdir -p ${IMAGE_CACHE}

# Create the cluster
echo "Creating cluster ${APPLICATION} with config from ${cluster_config_file}"
kind create cluster --name "${APPLICATION}" --config "${cluster_config_file}" --retain

echo "kind ready, check the README.md for the next steps."
