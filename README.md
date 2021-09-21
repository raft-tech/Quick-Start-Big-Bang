## --- NOTICE --- 
This readme is in the process of being updated to reflect raft's specific requirments for setting up bigbang in local dev, sandbox (Cloud, eg AWS), and on client infrastructure. There may be some inconsistancies or errors.

# Raft - Big Bang Quick Start

_This is a mirror of a government repo hosted on [Repo1](https://repo1.dso.mil/) by  [DoD Platform One](http://p1.dso.mil/).  Please direct all code changes, issues and comments to <https://repo1.dso.mil/platform-one/quick-start/big-bang>_

This is a small repo to help quickly test basic concepts of Big Bang on a local development machine.

---
## Prerequisites

### Hardware:

| Spec | CPU | RAM |
|------|-----|-----|
| Minimum | 6 | 16GB | 
| Recommended | 8+ | 32GB |  


### Software (Required):

| Name | Version |
|------|---------|
| [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) | >= 0.13.0 |
| [Docker](https://docs.docker.com/get-started/) | ? |
| [k3d](https://github.com/rancher/k3d) | ? |

### Software (Useful/Recommended):
| Name | Interface | Use |
| ---- | --------- | ---  |
| [Kubectl](https://kubernetes.io/docs/tasks/tools/) | CLI | Cluster Management |
| [K8s Lens](https://k8slens.dev/) | GUI | Cluster Management
| [K9s](https://k9scli.io/) | TUI | Cluster Management

---
## Instructions

Get your username and password from https://registry1.dso.mil and set them as env vars to be used later. The password to use is in your user profile under 'CLI secret'. If you don't have an account you can [register one](https://stackoverflow.com/c/raft/questions/25). Once you have the credentials, add them to your ```.bash_profile``` or equivilent as shown below.

```shell
export REGISTRY1_USERNAME="littlebobbytables"
export REGISTRY1_PASSWORD="correcthorsebatterystaple"
```

Create ```terraform.tfvars``` that will be gitignored (since it has secrets in it)

```shell
registry1_username = "${REGISTRY1_USERNAME}"
registry1_password = "${REGISTRY1_PASSWORD}"
```

**OPTIONAL:** Linux systems may require the following for EFK to not die.
```shell
sudo sysctl -w vm.max_map_count=262144
```

Initialize k3d. Your system will be automatically configured to use the right KUBECONTEXT.

```shell
./init-k3d.sh
```

Initialize & apply terraform. This will take several minutes. 

```shell
terraform init
terraform apply --auto-approve
```
Watch the deployments using kubectl, lens, or k9s until everything is: 
- STATUS = "Running" or "Complete"
- READY = "True"

```shell
watch -tn1 kubectl get kustomizations,hr,po -A
```

To get a list of http endpoints that will resolve to your localhost:
```shell
kubectl get virtualservices -A
```

## Services

| URL                                                          | Username  | Password                                                                                                                                                                                   | Notes                                                               |
| ------------------------------------------------------------ | --------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------- |
| [alertmanager.bigbang.dev](https://alertmanager.bigbang.dev) | n/a       | n/a                                                                                                                                                                                        | Unauthenticated                                                     |
| [grafana.bigbang.dev](https://grafana.bigbang.dev)           | `admin`   | `prom-operator`                                                                                                                                                                            |                                                                     |
| [kiali.bigbang.dev](https://kiali.bigbang.dev)               | n/a       | `kubectl get secret -n kiali -o=json \| jq -r '.items[] \| select(.metadata.annotations."kubernetes.io/service-account.name"=="kiali-service-account") \| .data.token' \| base64 -d; echo` |                                                                     |
| [kibana.bigbang.dev](https://kibana.bigbang.dev)             | `elastic` | `kubectl get secret -n logging logging-ek-es-elastic-user -o=jsonpath='{.data.elastic}' \| base64 -d; echo`                                                                                |                                                                     |
| [prometheus.bigbang.dev](https://prometheus.bigbang.dev)     | n/a       | n/a                                                                                                                                                                                        | Unauthenticated                                                     |
| [tracing.bigbang.dev](https://tracing.bigbang.dev)           | n/a       | n/a                                                                                                                                                                                        | Unauthenticated                                                     |
| [twistlock.bigbang.dev](https://twistlock.bigbang.dev)       | n/a       | n/a                                                                                                                                                                                        | Twistlock has you create an admin account the first time you log in |

---
## Teardown

**OPTION 1** - Using Teraform: Takes several minutes & reverts back to an empty cluster. However, it often leaves some custom resources.
```shell
terraform destroy
```

**OPTION 2** - Using k3d: Deletes cluster leaving a clean slate. Note that you need to delete the terraform state as you did not "properly" teardown the cluster
```shell
k3d cluster delete big-bang-quick-start
rm terraform.tfstate
```

---
## Makefile & AUTO DOCS

For your convenience, a Makefile is provided with targets `make up` and `make down`

#### --- AUTO GENERATED TF DOCS---
<!-- AUTOGENERATED CONTENT. TO UPDATE THIS SECTION RUN `terraform-docs .` -->
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.0 |

## Providers

No providers.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_registry1_password"></a> [registry1\_password](#input\_registry1\_password) | Your password on https://registry1.dso.mil. You can find it under 'CLI secret' in your user profile | `string` | n/a | yes |
| <a name="input_registry1_username"></a> [registry1\_username](#input\_registry1\_username) | Your username on https://registry1.dso.mil | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_external_load_balancer"></a> [external\_load\_balancer](#output\_external\_load\_balancer) | JSON array with information on all LoadBalancer services in the istio-system namespace. Example output:<pre>[<br>  {<br>    "name": "public-ingressgateway",<br>    "ip": "192.0.2.0",<br>    "hostname": "null"<br>  },<br>  {...}<br>]</pre> |
| <a name="output_istio_gw_ip"></a> [istio\_gw\_ip](#output\_istio\_gw\_ip) | DEPRECATED - Kept for backwards compatibility reasons, will be removed later. Returns the IP of the first LoadBalancer found in the istio-system namespace |
<!-- END_TF_DOCS -->
#### --- END OF AUTO GENERATED TF DOCS ---