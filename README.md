# Big Bang Quick Start

_This is a mirror of a government repo hosted on [Repo1](https://repo1.dso.mil/) by  [DoD Platform One](http://p1.dso.mil/).  Please direct all code changes, issues and comments to <https://repo1.dso.mil/platform-one/quick-start/big-bang>_

This is a small repo to help quickly test basic concepts of Big Bang on a local development machine.

---

## Prerequisites

What you need:

- [Docker](https://docs.docker.com/get-started/)
  - [Podman](https://podman.io) is also usable with kind.
- One of:
  - [k3d](https://github.com/rancher/k3d)
  - [kind](https://kind.sigs.k8s.io)
- [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
- VM or Machine with 
  - Bare minimum: 6 logical cpu cores and 16GB RAM
  - Recommended: 8+ cores and 32GB+ RAM

Nice to haves:

- [Kubectl](https://kubernetes.io/docs/tasks/tools/) - _CLI for working with k8s/k3d_
- [K8s Lens](https://k8slens.dev/) - _Handy GUI for kubectl_

## Instructions

```shell
# Get your username and password from https://registry1.dso.mil and set them as
# env vars to be used later. The password to use is in your user profile under
# 'CLI secret'. If you don't have an account you can register one on the 
# Platform One login page.
export REGISTRY1_USERNAME="bobbytables"
export REGISTRY1_PASSWORD="yourpasswordhere"

# Create a Terraform .tfvars file that will be gitignored (since it has secrets
# in it)
cat <<EOF >>terraform.tfvars
registry1_username = "${REGISTRY1_USERNAME}"
registry1_password = "${REGISTRY1_PASSWORD}"
EOF

# Linux systems may require this line for EFK to not die. Otherwise you can skip
# to the next command
sudo sysctl -w vm.max_map_count=262144

# Initialize k3d. Your system will be automatically configured to use the right
# KUBECONTEXT.
./init-k3d.sh

# You can also use kind (may have to make edits for non-linux systems)
# ./init-kind.sh

# Initialize & apply terraform. This will take several minutes.
# If you want to watch it happen use the next command under 
# "Watch the deployments" in a new terminal or other user interface
terraform init
terraform apply --auto-approve

# Watch the deployments. Wait for everything under STATUS to say "Running" and
# everything under READY to say "True"
watch kubectl get kustomizations,hr,po -A

# Get a list of http endpoints that will resolve to your localhost.
kubectl get virtualservices -A
```

### Services

| URL                                                          | Username  | Password                                                                                                                                                                                   | Notes                                                               |
| ------------------------------------------------------------ | --------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------- |
| [alertmanager.bigbang.dev](https://alertmanager.bigbang.dev) | n/a       | n/a                                                                                                                                                                                        | Unauthenticated                                                     |
| [grafana.bigbang.dev](https://grafana.bigbang.dev)           | `admin`   | `prom-operator`                                                                                                                                                                            |                                                                     |
| [kiali.bigbang.dev](https://kiali.bigbang.dev)               | n/a       | `kubectl get secret -n kiali -o=json \| jq -r '.items[] \| select(.metadata.annotations."kubernetes.io/service-account.name"=="kiali-service-account") \| .data.token' \| base64 -d; echo` |                                                                     |
| [kibana.bigbang.dev](https://kibana.bigbang.dev)             | `elastic` | `kubectl get secret -n logging logging-ek-es-elastic-user -o=jsonpath='{.data.elastic}' \| base64 -d; echo`                                                                                |                                                                     |
| [prometheus.bigbang.dev](https://prometheus.bigbang.dev)     | n/a       | n/a                                                                                                                                                                                        | Unauthenticated                                                     |
| [tracing.bigbang.dev](https://tracing.bigbang.dev)           | n/a       | n/a                                                                                                                                                                                        | Unauthenticated                                                     |
| [twistlock.bigbang.dev](https://twistlock.bigbang.dev)       | n/a       | n/a                                                                                                                                                                                        | Twistlock has you create an admin account the first time you log in |

### Teardown

```shell
# Big bang teardown (optional, takes several minutes & just reverts back to an
# empty cluster)
terraform destroy

# k3d teardown
k3d cluster delete big-bang-quick-start

# Delete Terraform state (if you didn't run `terraform destroy`)
rm terraform.tfstate
```

### Makefile

For your convenience, a Makefile is provided with targets `make up` and `make down`

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


### kind + Podman Rootless

[kind](https://kind.sigs.k8s.io) can run using rootless Podman (or Docker). See [their guide](https://kind.sigs.k8s.io/docs/user/rootless) on setting this up.


#### Running on Linux

Running this on a Linux system requires a few changes, mostly around open file limits.
See their guide on rootless and [known issues](https://kind.sigs.k8s.io/docs/user/known-issues/) for starting
information.
You may also have to make the following additions/edits:

Add/edit `/etc/systemd/system.conf.d/limits.conf` and `/etc/systemd/user.conf.d/limits.conf` to contain:

```ini
[Manager]
DefaultLimitNOFILE=65536
```

Edit `/etc/sysctl.conf` or add/edit a file under `/etc/sysctl.d/` to contain:

```ini
vm.max_map_count = 262144
fs.inotify.max_user_watches = 524288
fs.inotify.max_user_instances = 512
```

For podman, edit `/usr/share/containers/containers.conf` to contain:

```ini
...

# A list of ulimits to be set in containers by default, specified as
# "<ulimit name>=<soft limit>:<hard limit>", for example:
# "nofile=1024:2048"
# See setrlimit(2) for a list of resource names.
# Any limit not specified here will be inherited from the process launching the
# container engine.
# Ulimits has limits for non privileged container engines.
#
default_ulimits = [
 "nofile=65535:65535",
]

...
```
