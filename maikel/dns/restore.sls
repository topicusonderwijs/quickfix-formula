restore-primair-dns:
  cmd.run:
    - name: 'sed -i "s/172.25.240.11/192.168.3.220/g;s/172.25.240.12/192.168.3.221/g;s/172.25.240.13/192.168.3.222/g" /etc/resolv.conf /etc/sysconfig/network-scripts/ifcfg-*'

update-kubernetees-dns:
  cmd.run:
    - name: 'sed -i "s/172.25.240.11/192.168.3.221/g;s/172.25.240.12/192.168.3.222/g" /etc/resolv-kubernetes/resolv.conf'
    - onlyif:
        - fun: file.file_exists
          path: /etc/resolv-kubernetes/resolv.conf

restore-primair-refresh:
  module.run:
    - name: saltutil.refresh_grains

result-restore-primair-dns:
  cmd.run:
    - name: 'find /etc/resolv.conf /etc/sysconfig/network-scripts/ifcfg-* -print -exec cat {} \;'
