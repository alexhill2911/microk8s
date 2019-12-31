#!/bin/bash

host=$(hostname)

# enable registry addon
microk8s.enable registry
microk8s.status --wait-ready

cat << EOF > /etc/docker/daemon.json
{   "insecure-registries" : ["$host:32000"], 
    "default-runtime": "nvidia",
    "runtimes": {
        "nvidia": {
            "path": "nvidia-container-runtime",
            "runtimeArgs": []
        }
    }
}
EOF

# reload daemon to clear cache
systemctl daemon-reload

# Restart Docker
systemctl restart docker

# verify registry 
kubectl get all -n contaner-resgistry

echo "Edit /var/snap/microk8s/current/args/containerd-template.toml"
echo " add the following under [plugins] -> [plugins.cri.registry] -> [plugins.cri.registry.mirrors]"
echo "The stop and start microk8s"
echo " "
echo "        [plugins.cri.registry.mirrors."localhost:32000"]"
echo "          endpoint = ["http://localhost:32000"]"
