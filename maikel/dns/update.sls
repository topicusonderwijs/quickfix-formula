update-primair-dns:
  cmd.run:
    - name: 'sed -i "s/192.168.3.220/172.25.240.11/g;s/192.168.3.221/172.25.240.12/g;s/192.168.3.222/172.25.240.13/g" /etc/resolv.conf /etc/sysconfig/network-scripts/ifcfg-*'

update-primair-refresh:
  module.run:
    - name: saltutil.refresh_grains

result-update-primair-dns:
  cmd.run:
    - name: 'find /etc/resolv.conf /etc/sysconfig/network-scripts/ifcfg-* -print -exec cat {} \;'
