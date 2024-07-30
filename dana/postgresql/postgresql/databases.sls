# -*- coding: utf-8 -*-
# vim: ft=yaml ts=2 sw=2 expandtab

{% from "postgresql/map.jinja" import postgresql with context %}
{% for instance_name, instance in postgresql.instance.items() %}

{% if not instance.is_standby | default(False) %}
{% if instance.running | default(True) %}
{% for db in instance.databases | default([]) %}
{{ instance_name }}_postgresql-database-{{ db.name }}:
  postgres_database.present:
    - name: {{ db.name }}
  {%- if db.tablespace is defined %}
    - tablespace: {{ db.tablespace }}
  {%- endif %}

  {%- if db.encoding is defined %}
    - encoding: {{ db.encoding }}
  {%- endif %}

  {%- if db.lc_collate is defined %}
    - lc_collate: {{ db.lc_collate }}
  {%- endif %}

  {%- if db.lc_ctype is defined %}
    - lc_ctype: {{ db.lc_ctype }}
  {%- endif %}

  {%- if db.owner is defined %}
    - owner: {{ db.owner }}
  {%- endif %}

  {%- if db.owner_recurse is defined %}
    - owner_recurse: {{ db.owner_recurse | default(False) }}
  {%- endif %}

  {%- if db.template is defined %}
    - template: {{ db.template }} 
  {%- endif %}

    - user: postgres

  {%- if db.db_user is defined %}
    - db_user: {{ db.db_user }}
  {%- endif %}

  {%- if db.db_password is defined %}
    - db_password: {{ db.db_password }}
  {%- endif %}
  {% if instance.settings.port is defined %}
    - db_port: {{ instance.settings.port }}
  {% endif %}
    - require:
      - service: {{ instance_name }}_postgresql-service
  {%- for role in instance.roles | default([]) %}
      - postgres_user: {{ instance_name }}_postgresql-role-{{ role.name }}
  {%- endfor %}
{% endfor %}
{% endif %}
{% endif %}
{% endfor %}
