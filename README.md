# 1 Docker
1 - Build
    docker image build -t lasynsec/demo-1030:1.0 .\demo-app\App
2 - push
    docker image push lasynsec/demo-1030:1.0
3 - run 
    docker run -d -p 8080:80 --name  lasynsec/demo-1030:1.0
4 - delete
    docker run -d -p 8080:80 --name  lasynsec/demo-1030:1.0
# 2 Docker-Compose


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
    $ talosctl gen secrets --output-file _out/secrets.yaml
    
    B# Generate machine configuration (execute the powershell : generate-config.ps1)
    talosctl gen config demo-cluster https://192.168.56.104:6443 # VIP Endpoint\
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

4 - configure talosctl to talk the control planes

    # Set env variable via Powershell
    $env:TALOSCONFIG = "./rendered/talosconfig"
    
    # Set the endpoints for loadbalancing
    talosctl config endpoint 192.168.56.110 192.168.56.111 192.168.56.112

5 - configure a default node to target with Talos command

    talosctl config node 192.168.56.110

6 - Bootstrap etcd in a node(any node)

    talosctl bootstrap -n 192.168.56.110
    
7 - Watch logs in the real-time

    talosctl dashboard -n 192.168.56.110

8 - Fetch the Kubeconfig for the cluster (running against any node)

    talosctl kubeconfig -n 192.168.56.110

9 - Get current cluster

    kubectl config get-contexts

10 - Deploying and running manually the demo app to the cluster

    kubectl create deployment web-ctr --image lasynsec/demo-1030:1.0 --replicas 1
    kubectl expose deployment web-ctr --type NodePort --port 8080

11 - Delete deployment and service
    
    kubectl.exe delete web-ctr
    kubectl.exe delete svc web-ctr

12 - Auto-Healing Pod (Réparation automatique)

    A - kubectl.exe apply -f .\svc-local.yml
    B - kubectl.exe apply -f .\deploy.yml
    C - kubectl.exe delete pod [pod-name]
    D - kubectl.exe get pods --watch

13 - Rolling-Update (Mise à jour continue)

    A - Modifier code
    B - docker image build -t lasynsec/demo-1030:1.1 .\demo-app\App
    C - docker image push lasynsec/demo-1030:1.1
    D - kubectl.exe apply -f .\deploy.yml
    E - kubectl.exe rollout status deployment demo-deploy

14 - Test High Availability
    A - Shotdown current VIP leader vm & watch Pods transfert to new VIP leader
    B - kubectl.exe get pods -o wide


 
