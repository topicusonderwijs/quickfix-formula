# -*- coding: utf-8 -*-
# vim: ft=yaml ts=2 sw=2 expandtab

{% from "postgresql/map.jinja" import postgresql with context %}
{% for instance_name, instance in postgresql.instance.items() %}

{% if not instance.is_standby | default(False) %}
{% if instance.running | default(True) %}
{%- for ext in instance.extensions | default([]) %}
{{ instance_name }}_postgresql-extension-{{ ext.name }}:
  postgres_extension.present:
    - name: {{ ext.name }}
  {%- if ext.if_not_exists is defined %}
    - if_not_exists: {{ ext.if_not_exists }}
  {%- endif %}
  {%- if ext.schema is defined %}
    - schema: {{ ext.schema }}
  {%- endif %}
  {%- if ext.ext_version is defined %}
    - ext_version: {{ ext.ext_version }}
  {%- endif %}
  {%- if ext.from_version is defined %}
    - from_version: {{ ext.from_version }}
  {%- endif %}
  {%- if ext.user is defined %}
    - user: {{ ext.user }}
  {%- endif %}
  {%- if ext.maintenance_db is defined %}
    - maintenance_db: {{ ext.maintenance_db }}
  {%- endif %}
  {% if instance.settings.port is defined %}
    - db_port: {{ instance.settings.port }}
  {% endif %}
    - require:
      - service: {{ instance_name }}_postgresql-service
  {%- for role in instance.roles | default([]) %}
      - postgres_user: {{ instance_name }}_postgresql-role-{{ role.name }}
  {%- endfor %}
  {%- for db in instance.databases | default([]) %}
      - postgres_database: {{ instance_name }}_postgresql-database-{{ db.name }}
  {%- endfor %}
{%- endfor %}
{% endif %}
{% endif %}
{%- endfor %}
