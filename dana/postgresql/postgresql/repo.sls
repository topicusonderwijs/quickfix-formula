# -*- coding: utf-8 -*-
# vim: ft=yaml ts=2 sw=2 expandtab

{% from "postgresql/map.jinja" import postgresql with context %}

{% set rpm_repo_key = '/etc/pki/rpm-gpg/RPM-GPG-KEY-PGDG' %}

{# range is _up to_ not _including_ #}
{%- for i in range(10, 12) %}
postgresql {{ i }} repo absent:
  file.absent:
    - name: /etc/yum.repos.d/pgdg{{ i }}.repo 
{%- endfor %}

postgresql-repo-key:
  file.managed: 
    - name: {{ rpm_repo_key }}
    - contents: {{ postgresql.gpgkey | yaml }}
    - user: root
    - group: root
    - mode: 644

{%- for repo in postgresql['repositories'] %}
postgresql-repo-{{ repo.name }}:
  pkgrepo.managed:
    - name: {{ repo.name }}
    - baseurl: {{ repo.baseurl }}
    - enabled: {{ repo.enabled }}
    - gpgcheck: {{ repo.gpgcheck }}    
    - gpgkey: file://{{ rpm_repo_key }}
    - require:
      - file: postgresql-repo-key
    {%- if grains.osfinger == 'AlmaLinux-8' %}
    - watch_in:
      - cmd: disable postgresql dnf module
    {%- endif %}
{%- endfor %}

{# 
 # In AlmaLinux-8 disable the module postgresql
 # from alma's repositories. Without this postgresql
 # will not install from the proper repository #}
{% if grains.osfinger == 'AlmaLinux-8' %}
disable postgresql dnf module:
  cmd.wait:
    - name: dnf -qy module disable postgresql
{% endif %}
