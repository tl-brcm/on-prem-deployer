## Intro
This is the guide for deployment of SiteMinder container in A Client environment, 

## Background
A client is using Openshift 1.25 and with single namespace.  SC is also using a private repo so all the helm charts and docker images must reside there. 

## Pre-req
You will need below setups for deployment
- Openshift or K8S ver 1.27+ 
- We assume you already have ingress controller running in your space. 
- We assume you have logging and monitoring framework in your infra e.g. Elasticsearch and Prometheus. 

## Download required images and push to private repo

Download all the .tgz files from the case, which includes all the required images

Put all the files under your project_home/image_files dir, and create the folder if it's not there. 

Run `script_docker/load_images.sh` script to load all the images into your docker/podman env. e.g. 

```sh
script_docker/load_images.sh image_files/ podman
```

Verify the images are loaded 
```sh
docker images
```

And the file 
```sh
cat loaded_image_list
```


Now you can run the below script to tag and push image to your private repo. 

Take note that you might need to login to your private repo before running the script

```sh
podman login artifactory.k3s.demo
```

Replace `artifactory.k3s.demo` with your own private repo name

```sh
script_docker/tag_push_images.sh ./loaded_image_list artifactory.k3s.demo/brcm-docker podman
```

Here artifactory.k3s.demo is the repo's domain, and brcm-docker is your docker repo name, which can be found at your artifactory. 

Next you can push the helm chart to your private repo. Run below script

```sh
./push_helm_chart.sh ../helm_charts/server-components-1.0.3100.tgz https://artifactory.k3s.demo/artifactory/brcm-helm/server-components-1.0.3100.tgz admin password
./push_helm_chart.sh ../helm_charts/ssp-symantec-dir-2.2.2+1012.tgz https://artifactory.k3s.demo/artifactory/brcm-helm/ssp-symantec-dir-2.2.2+1012.tgz admin password
```
Replace the helm username and password, and your helm artifactory url as well. 


## Deploy CA Dir server (Optional)
If you dont have a policy store, you can run below to deploy it. 
First checkout the sm-container git at 
```
git clone git@github.com:tl-brcm/sm-container.git
```

Switch to [private-repo-single-ns](https://github.com/tl-brcm/sm-container/tree/private-repo-single-ns)

### Create ds Config File
```sh
kubectl create configmap sm-schemas --from-file ../envs/democadir/schema/ -n namespace
```
This command creates a configmap named `sm-schemas` from files in the specified directory, within the given namespace.

### Create a ldif Config Map
```sh
kubectl create configmap sm-root-ldif --from-file ../review/sm-root.ldif -n namespace
```
This command creates a configmap named `sm-root-ldif` from the specified LDIF file, within the given namespace.

### Check the Values File from the Repo
```sh
helm repo update
helm install pstore brcm-helm/ssp-symantec-dir -f cadir-values.yaml --insecure-skip-tls-verify -n namespace
```
These commands first update the Helm repository and then install the chart `ssp-symantec-dir` from the `brcm-helm` repository, using the `cadir-values.yaml` file for configuration values, skipping TLS verification, and specifying the namespace for the deployment.

Remember to replace `namespace` with the actual namespace you want to use in each command. If you're applying these commands in different namespaces, you'll need to change the namespace accordingly in each command.

Replace `brcm-helm` with your actual private repo name. 

## Deploy SM policy server

From the sm-container repo, update your `base/env.shlib` file accordingly with your namespace, helm and docker username and passwords.  

Next update your `envs/democadir/ps-values.yaml` file . 
Take note: 
1. Replace your registry URL. Currently it's artifactory.k3s.demo. Find all these keywords and replace
2. Update the credential with your docker pull cred. 
3. The service name of your policy store, you must find all keywords of `single` and replace with your actual namespace. 


Run build/smps.sh to deploy the policy server. 