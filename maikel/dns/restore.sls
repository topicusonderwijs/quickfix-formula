restore-primair-dns:
  cmd.run:
    - name: 'sed -i "s/10.64.1.51/192.168.22.142/g;s/10.64.1.52/192.168.22.143/g;s/10.64.1.53/192.168.22.146/g" /etc/resolv.conf /etc/sysconfig/network-scripts/ifcfg-*'

update-kubernetees-dns:
  cmd.run:
    - name: 'sed -i "s/10.64.1.51/192.168.22.142/g;s/10.64.1.52/192.168.22.143/g;s/10.64.1.53/192.168.22.146/g" /etc/resolv-kubernetes/resolv.conf'
    - onlyif:
        - fun: file.file_exists
          path: /etc/resolv-kubernetes/resolv.conf


update-kubernetees-dns:
  cmd.run:
    - name: 'sed -i "s/10.64.1.51/192.168.22.142/g;s/10.64.1.52/192.168.22.143/g;s/10.64.1.53/192.168.22.146/g" /etc/rancher/rke2/resolv.conf'
    - onlyif:
        - fun: file.file_exists
          path: /etc/rancher/rke2/resolv.conf


restore-primair-refresh:
  module.run:
    - name: saltutil.refresh_grains

result-restore-primair-dns:
  cmd.run:
    - name: 'find /etc/resolv.conf /etc/sysconfig/network-scripts/ifcfg-* -print -exec cat {} \;'
