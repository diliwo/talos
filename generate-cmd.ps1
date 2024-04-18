  talosctl.exe gen config talos-demo-cluster https://192.168.56.254:6443 `
  --with-secrets _out/secrets.yaml `
  --config-patch @_out/patches/allow-controlplane-workloads.yaml `
  --config-patch @_out/patches/cni.yaml `
  --config-patch @_out/patches/dhcp.yaml `
  --config-patch @_out/patches/interface-names.yaml `
  --config-patch @_out/patches/kubelet-certificates.yaml `
  --config-patch-control-plane @_out/patches/vip.yaml `
  --output rendered/