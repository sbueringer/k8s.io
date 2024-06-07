# vCenter

Create via:
```bash
# Create terraform.tfvars in vsphere folder:
# vsphere_password = ""
# vsphere_server = ""
# vsphere_user = "cloudadmin@vmc.local"

cd ./vsphere

docker run -ti --rm -v $(pwd):/data ubuntu:22.04 /bin/bash

cd /data
apt-get update
apt-get install -y curl vim
# tfswitch install to manage terraform version
curl -L https://raw.githubusercontent.com/warrensbox/terraform-switcher/master/install.sh | bash
# Run tfswitch to download terraform
tfswitch

# Run terraform
terraform init
terraform plan
terraform apply
```

# Boskos


```bash
cd ./boskos

export KUBECONFIG=***

kubectl apply -f ./boskos/namespace.yaml
kubectl apply -f ./boskos/boskos-resources-configmap.yaml
kubectl apply -f ./boskos/boskos.yaml
kubectl apply -f ./boskos/boskos-reaper-deployment.yaml
```

Init resources

```bash
cd ./boskos

export BOSKOS_HOST=http://192.168.6.138:32222

# Check connectivity
curl -k -v ${BOSKOS_HOST}/metrics

# Acquire all resources (repeat command until all are acquired)
# Initializing
while true; do curl -X POST "${BOSKOS_HOST}/acquire?type=vsphere-project-cloud-provider&state=initializing&dest=busy&owner=$(whoami)"; done
while true; do curl -X POST "${BOSKOS_HOST}/acquire?type=vsphere-project-cluster-api-provider&state=initializing&dest=busy&owner=$(whoami)"; done
while true; do curl -X POST "${BOSKOS_HOST}/acquire?type=vsphere-project-image-builder&state=initializing&dest=busy&owner=$(whoami)"; done

# Free
while true; do curl -X POST "${BOSKOS_HOST}/acquire?type=vsphere-project-cloud-provider&state=free&dest=busy&owner=$(whoami)"; done
while true; do curl -X POST "${BOSKOS_HOST}/acquire?type=vsphere-project-cluster-api-provider&state=free&dest=busy&owner=$(whoami)"; done
while true; do curl -X POST "${BOSKOS_HOST}/acquire?type=vsphere-project-image-builder&state=free&dest=busy&owner=$(whoami)"; done

# Dirty
while true; do curl -X POST "${BOSKOS_HOST}/acquire?type=vsphere-project-cloud-provider&state=dirty&dest=busy&owner=$(whoami)"; done
while true; do curl -X POST "${BOSKOS_HOST}/acquire?type=vsphere-project-cluster-api-provider&state=dirty&dest=busy&owner=$(whoami)"; done
while true; do curl -X POST "${BOSKOS_HOST}/acquire?type=vsphere-project-image-builder&state=dirty&dest=busy&owner=$(whoami)"; done


# Add user data (using homebrew / mikefarah/yq)
for resourceType in $(yq eval '.resources[].type' boskos-resources-user-data.yaml); do
  echo "Adding userdata to resources of type $resourceType"
  for resourceName in $(yq eval '.resources[] | select(.type=="'$resourceType'") | .resources[].name' boskos-resources-user-data.yaml); do
    echo "Adding userdata to resource $resourceName"
    
    userData=$(yq eval '.resources[] | select(.type=="'${resourceType}'") | .resources[] | select(.name=="'${resourceName}'") | .userData' boskos-resources-user-data.yaml)
    
    resourcePool="$(echo $userData | yq eval '.resourcePool')" 
    folder="$(echo $userData | yq eval '.folder')" 
    ipPool="$(echo $userData | yq eval '.ipPool')"
    
    curl -X POST -d '{"ipPool":"'${ipPool}'","resourcePool":"'${resourcePool}'","folder":"'${folder}'"}' "${BOSKOS_HOST}/update?name=${resourceName}&state=busy&owner=$(whoami)" -v
  done
done

# Release resources
for resourceType in $(yq eval '.resources[].type' boskos-resources-user-data.yaml); do
  echo "Releasing resources of type $resourceType"
  for resourceName in $(yq eval '.resources[] | select(.type=="'$resourceType'") | .resources[].name' boskos-resources-user-data.yaml); do
    echo "Releasing resource $resourceName"
    curl -X POST "${BOSKOS_HOST}/release?name=${resourceName}&dest=free&owner=$(whoami)" 
  done
done
```
