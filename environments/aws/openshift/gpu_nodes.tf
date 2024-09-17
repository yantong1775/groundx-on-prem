data "external" "cluster_name" {
  program = [
    "sh", "-c", "name=$(oc get infrastructure cluster -o jsonpath='{.status.infrastructureName}'); jq -n --arg name \"$name\" '{\"cluster_name\": $name}'"
  ]
}

resource "helm_release" "gpu_node" {
  count = 0

  name       = "${data.external.cluster_name.result.cluster_name}-gpu-us-east-2a"
  namespace  = "openshift-machine-api"
  chart      = "${local.module_path}/gpu-node/openshift/helm_chart"

  values = [
    yamlencode({
      ami              = "ami-0686d1a86db8aeeb1"
      cluster          = data.external.cluster_name.result.cluster_name
      gpu_memory       = "16gb"
      instanceType     = "g4dn.xlarge"
      keyName          = "benohio"
      minReplicas      = 1
      maxReplicas      = 10
      name             = "${data.external.cluster_name.result.cluster_name}-gpu-us-east-2a"
      namespace        = "openshift-machine-api"
      region           = "us-east-2"
      replicas         = 1
      role             = "gpu"
      securityGroup    = "sg-064cc9d6445b12e19"
      storage          = {
        volumeSize     = 120
        volumeType     = "gp2"
      }
      zone             = "us-east-2a"
    })
  ]
}