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
    
    B# Generate machine configuration (execute the powershell : generate-cmd.ps1)
    talosctl gen config demo-cluster https://192.168.56.104:6443 \
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
            
3 - Configure all cluster nodes in Talos

        talosctl apply -f rendered/controlplane.yaml -n 192.168.56.101 --insecure
        talosctl apply -f rendered/controlplane.yaml -n 192.168.56.102 --insecure
        talosctl apply -f rendered/controlplane.yaml -n 192.168.56.103 --insecure

4 - configure talosctl to talk the control planes

    # Set env variable via Powershell
    $env:TALOSCONFIG = "./rendered/talosconfig"
    
    # Set the endpoints for loadbalancing
    talosctl config endpoint 192.168.56.104 192.168.56.105 192.168.56.106

5 - configure a default node to target with Talos command

    talosctl config node 192.168.56.104

6 - Bootstrap etcd in a node(any node)

    talosctl bootstrap -n 192.168.56.104
    
7 - Watch logs in the real-time

    talosctl dashboard -n 192.168.56.104

8 - Fetch the Kubeconfig for the cluster (running against any node)

    talosctl kubeconfig -n 192.168.56.104

10 - Deploying and running a pod to the cluster

    kubectl create deployment nginx-demo --image nginx --replicas 1
    kubectl expose deployment nginx-demo --type NodePort --port 80




 
