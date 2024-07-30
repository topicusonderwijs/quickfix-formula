# -*- coding: utf-8 -*-
# vim: ft=yaml ts=2 sw=2 expandtab

{% from "postgresql/map.jinja" import postgresql with context %}

{% for instance_name, instance in postgresql.instance.items() %}
{% if not instance.is_standby | default(False) %}
{% if instance.running | default(True) %}
{% for role in instance.roles | default([]) %}
{{ instance_name }}_postgresql-role-{{ role.name }}:
  postgres_user.present:
    - name: {{ role.name }}
  {% if role.createdb is defined %}
    - createdb: {{ role.createdb }}
  {% endif %}
  {% if role.createroles is defined %}
    - createroles: {{ role.createroles }}
  {% endif %}
  {% if role.encrypted is defined %}
    - encrypted: {{ role.encrypted }}
  {% endif %}
  {% if role.login is defined %}
    - login: {{ role.login }}
  {% endif %}
  {% if role.inherit is defined %}
    - inherit: {{ role.inherit }}
  {% endif %}
  {% if role.superuser is defined %}
    - superuser: {{ role.superuser }}
  {% endif %}
  {% if role.replication is defined %}
    - replication: {{ role.replication }}
  {% endif %}
  {% if role.password is defined %}
    - password: {{ role.password }}
  {% endif %}
  {% if role.default_password is defined %}
    - default_password: {{ role.default_password }}
  {% endif %}
  {% if role.refresh_password is defined %}
    - refresh_password: {{ role.refresh_password }}
  {% endif %}
  {% if role.valid_until is defined %}
    - valid_until: {{ role.valid_until }}
  {% endif %}
  {% if role.groups is defined %}
    - groups: {{ role.groups }}
  {% endif %}
  {% if role.user is defined %}
    - user: {{ role.user }}
  {% endif %}
  {% if role.db_user is defined %}
    - db_user: {{ role.db_user }}
  {% endif %}
  {% if role.db_password is defined %}
    - db_password: {{ role.db_password }}
  {% endif %}
  {% if instance.settings.port is defined %}
    - db_port: {{ instance.settings.port }}
  {% endif %}
    - require:
      - service: {{ instance_name }}_postgresql-service
{% endfor %}
{% endif %}
{% endif %}
{% endfor %}
