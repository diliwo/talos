# 1 Docker

1 - Build app in image :
    docker image build -t lasynsec/demo-1030:1.0 .\demo-app\App
2 - push iamge :
    docker image push lasynsec/demo-1030:1.0
3 - run and remove container :
    docker run --rm -d --name web-app -p 8080:8080 lasynsec/demo-1030:1.0
4 - delete image :
    docker image rm lasynsec/demo-1030:1.0
    
# 2 Docker-Compose

1 - Build and run docker isp api on isp-web-api project folder
    docker-compose up -d --build

2 - Build and run docker appi web on appi-web-app project folder
    docker compose -f .\docker-compose.yml up --build -d

3 - Import Beneficiary for the test
    Nis : 74123144173

# 3 Kubernets & Talos Linux

Releases : https://github.com/siderolabs/talos/releases
Docs : https://www.talos.dev/v1.5/reference/configuration/#clusterconfig

1 - Install Talosctl and Kubectl on a local machine (Windows)

    # install Talosctl
    $ choco install talosctl
    
    # install Kubectl
    $ choco install kubernetes-cli

2 - Installation steps Talos Linux & Kubernetes on Vms :

    A# Generate secretes bundle
        talosctl gen secrets --output-file _out/secrets.yaml
    
    B# Generate machine configuration (execute the powershell : generate-config.ps1)
    talosctl gen config demo-cluster https://192.168.56.254:6443 # VIP Endpoint\
      --with-secrets secrets.yaml \
      --config-patch @patches/allow-controlplane-workloads.yaml \
      --config-patch @patches/cni.yaml \
      --config-patch @patches/dhcp.yaml \
      --config-patch @patches/install-disk.yaml \
      --config-patch @patches/interface-names.yaml \
      --config-patch @patches/kubelet-certificates.yaml \
      --config-patch-control-plane @patches/vip.yaml \
      --output rendered/
    
    C# Les fichiers suivants seront générés dans le dossier rendered :
            - controlplane.yaml
            - worker.yaml
            - talosconfig.yaml
            
3 - Configure all cluster nodes in Talos ((execute the powershell : create-controlplanes.ps1))

    talosctl apply -f rendered/controlplane.yaml -n [IP-1] --insecure
    talosctl apply -f rendered/controlplane.yaml -n [IP-2] --insecure
    talosctl apply -f rendered/controlplane.yaml -n [IP-3] --insecure

#########################################
Wait for Vm auto configuration !!!!!!!!!!
#########################################

4 - configure talosctl to talk to the control planes

    # Set env variable via Powershell
    $env:TALOSCONFIG = "./rendered/talosconfig"
    
    # Set the endpoints for loadbalancing
    talosctl config endpoint 192.168.56.113 192.168.56.114 192.168.56.115

5 - configure a default node to target with Talos command

    talosctl config node 192.168.56.113

6 - Bootstrap etcd in a node(any node) and watch logs

    A# - talosctl bootstrap -n 192.168.56.113
    B# - talosctl -n 192.168.56.113 logs etcd

###########################
Here all machines are ready
###########################
    
7 - Watch logs in the real-time

    talosctl dashboard -n 192.168.56.113

8 - Fetch the Kubeconfig for the cluster (running against any node)

    talosctl kubeconfig -n 192.168.56.113

9 - Get current cluster

    kubectl config get-contexts

10 - Deploying and running manually the demo app to the cluster

    kubectl create deployment web-ctr --image lasynsec/demo-1030:1.0 --replicas 1
    kubectl expose deployment web-ctr --type NodePort --port 8080

11 - Delete deployment and service
    
    kubectl.exe delete deploy web-ctr
    kubectl.exe delete svc web-ctr

12 - Auto-Healing Pod (Réparation automatique)

    A - kubectl.exe apply -f .\demo-app\svc-local.yml
    B - kubectl.exe apply -f .\demo-app\deploy.yml
    C - kubectl.exe delete pod [pod-name]
    D - kubectl.exe get pods --watch

13 - Rolling-Update (Mise à jour continue)

    A - Modifier code
    B - docker image build -t lasynsec/demo-1030:1.1 .\demo-app\App
    C - docker image push lasynsec/demo-1030:1.1
    D - kubectl.exe apply -f .\demo-app\deploy.yml
    E - kubectl.exe rollout status deployment demo-deploy

14 - Test High Availability
    A - Shotdown current VIP leader vm & watch Pods transfert to new VIP leader
    B - kubectl.exe get pods -o wide


 
