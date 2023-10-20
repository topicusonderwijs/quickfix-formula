update-primair-dns:
  cmd.run:
    - name: 'sed -i "s/192.168.22.142/10.64.1.51/g;s/192.168.22.143/10.64.1.52/g;s/192.168.22.146/10.64.1.53/g" /etc/resolv.conf /etc/sysconfig/network-scripts/ifcfg-*'

update-kubernetes-dns:
  cmd.run:
    - name: 'sed -i "s/192.168.22.142/10.64.1.51/g;s/192.168.22.143/10.64.1.52/g;s/192.168.22.146/10.64.1.53/g" /etc/resolv-kubernetes/resolv.conf'
    - onlyif:
      - fun: file.file_exists
        path: /etc/resolv-kubernetes/resolv.conf

update-rke2-dns:
  cmd.run:
    - name: 'sed -i "s/192.168.22.142/10.64.1.51/g;s/192.168.22.143/10.64.1.52/g;s/192.168.22.146/10.64.1.53/g" /etc/rancher/rke2/resolv.conf'
    - onlyif:
      - fun: file.file_exists
        path: /etc/rancher/rke2/resolv.conf


update-primair-refresh:
  module.run:
    - name: saltutil.refresh_grains

result-update-primair-dns:
  cmd.run:
    - name: 'find /etc/resolv.conf /etc/sysconfig/network-scripts/ifcfg-* -print -exec cat {} \;'
