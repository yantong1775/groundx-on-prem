kubectl create ns nvidia-gpu-operator
kubectl apply -n nvidia-gpu-operator -f gpu-operator-quota.yaml
kubectl apply -f https://raw.githubusercontent.com/GoogleCloudPlatform/container-engine-accelerators/master/nvidia-driver-installer/cos/daemonset-preloaded.yaml
helm install --wait --generate-name \
    -n nvidia-gpu-operator \
    nvidia/gpu-operator \
    --version=v24.9.2 \
    --set hostPaths.driverInstallDir=/home/kubernetes/bin/nvidia \
    --set toolkit.installDir=/home/kubernetes/bin/nvidia \
    --set cdi.enabled=true \
    --set cdi.default=true \
    --set driver.enabled=false \
    --set migManager.enabled=false

terraform apply -auto-approve