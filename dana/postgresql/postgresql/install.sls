# -*- coding: utf-8 -*-
# vim: ft=yaml ts=2 sw=2 expandtab

{% from "postgresql/map.jinja" import postgresql with context %}

{% for instance_name, instance in postgresql.instance.items() %}
  {% set version = instance.version %}

{{ instance_name }}_postgresql-packages:
  pkg.installed:
    - pkgs: 
      - postgresql{{ version }}
      - postgresql{{ version }}-server
      - postgresql{{ version }}-contrib
      - pgbackrest
    {%- for repo in postgresql['repositories'] %}
    - require:
      - pkgrepo: postgresql-repo-{{ repo.name }}
    {%- endfor %}

{{ instance_name }}_postgresql_systemd_service_unit:
  file.managed:
    - name: /etc/systemd/system/postgresql-{{ version }}@.service
    - user: root
    - group: root
    - source: salt://postgresql/files/postgresql.service.tmpl
    - template: jinja
    - context:
        data: {{ version }}
    - onchanges_in:
      - cmd: postgresql_systemd_reload

{%- if instance.extra_packages|default(false) %}
{{ instance_name }}_postgresql-extra-packages:
  pkg.installed:
    - pkgs:
      - postgresql{{ version }}-plperl
    {%- for repo in postgresql['repositories'] %}
    - require:
      - pkgrepo: postgresql-repo-{{ repo.name }}
    {%- endfor %}
{%- endif %}


{% endfor %}


postgresql_systemd_reload:
  cmd.run:
    - name: systemctl daemon-reload
