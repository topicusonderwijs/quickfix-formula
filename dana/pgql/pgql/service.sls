# -*- coding: utf-8 -*-
# vim: ft=yaml ts=2 sw=2 expandtab

{% from "postgresql/map.jinja" import postgresql with context %}
{% for instance_name, instance in postgresql.instance.items() %}
  {% set version = instance.version %}

{{ instance_name }}_postgresql-service:
  {% if instance.running | default(True) %}
  service.running:
  {% else %}
  service.dead:
  {% endif %}
    - name: postgresql-{{version}}@{{ instance_name }}
    - enable: {{ instance.running | default(True) }}

{% endfor %}
