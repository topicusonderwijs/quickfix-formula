{%- set minionid=grains.get('id') %}

{% set etcd_data = { "A":"aaa", "B":"bbb" } %}

etcd_test_set:
  etcd3.setsubtree:
    - name: /prometheus/sd/{{minionid}}/label
    - data: "blabla"
    - profile: etcd_prom_sd

etcd_test_subtree:
  etcd3.setsubtree:
    - name: /prometheus/sd/{{minionid}}/job/node-exporter/
    - data: {{ etcd_data | yaml }}
    - profile: etcd_prom_sd
