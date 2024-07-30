# -*- coding: utf-8 -*-
# vim: ft=yaml sw=2 ts=2 expandtab
{% from "postgresql/map.jinja" import postgresql with context %}

{% set pg_root_dir = postgresql.root_dir %}

postgresql-rootdir:
  file.directory:
    - name: {{ pg_root_dir }}
    - mode: 700
    - user: postgres
    - group: postgres

# We only create the file with the appropriate rights here. Contents will be
# appended in instance sections.
pgpass file:
  file.managed:
    - name: {{ pg_root_dir }}/.pgpass
    - user: postgres
    - group: postgres
    - mode: 600

{% for instance_name, instance in postgresql.instance.items() %}
  {% set version = instance.version %}

  {% if instance.pgdata_override is defined %}
    {% set pg_data_dir = instance.pgdata_override %}
  {% else %}
    {% set pg_data_dir = pg_root_dir + '/' ~ version ~ '/' ~ instance_name %}
  {% endif %}

  {% set pg_bin_dir = '/usr/pgsql-' ~ version ~ '/bin' %}


{{ instance_name }}_environment_file:
  file.managed:
    - name: /etc/default/postgresql{{version}}-{{ instance_name }}
    - user: root
    - group: root
    - contents: |
        ### This file is managed by Saltstack
        ### Changes WILL be overwritten
        {%- if instance.pgdata_override is defined %}
        PGDATA={{ instance.pgdata_override }}
        {%- else %}
        PGDATA={{ pg_root_dir }}/{{ version }}/{{ instance_name }}
        {%- endif %}
        ### EOF ###

{{ instance_name }}_sudoers_file:
  file.managed:
    - name: /etc/sudoers.d/postgresql-{{ instance_name }}
    - user: root
    - group: root
    - mode: 0220
    - contents: |
        ### This file is managed by Saltstack
        ### Changes WILL be overwritten
        postgres    ALL=(ALL:ALL) NOPASSWD: /bin/systemctl start postgresql-{{ version }}@{{ instance_name }}.service
        postgres    ALL=(ALL:ALL) NOPASSWD: /bin/systemctl stop postgresql-{{ version }}@{{ instance_name }}.service
        postgres    ALL=(ALL:ALL) NOPASSWD: /bin/systemctl restart postgresql-{{ version }}@{{ instance_name }}.service
        postgres    ALL=(ALL:ALL) NOPASSWD: /bin/systemctl reload postgresql-{{ version }}@{{ instance_name }}.service
        postgres    ALL=(ALL:ALL) NOPASSWD: /bin/systemctl status postgresql-{{ version }}@{{ instance_name }}.service
        postgres    ALL=(ALL:ALL) NOPASSWD: /usr/bin/salt-call state.test postgresql
        postgres    ALL=(ALL:ALL) NOPASSWD: /usr/bin/salt-call state.apply postgresql
        ### EOF ###

{{ instance_name }}_postgresql-initdb:
{% if instance.is_standby | default(False) %}
{% set cfg = instance.standby_config %}
  file.append:
    - name: {{ pg_root_dir }}/.pgpass
    - text: |
        {{ cfg.remote_host }}:{{ cfg.remote_port|default(5432) }}:*:{{ cfg.remote_user }}:{{ cfg.remote_password}}
  cmd.run:
    - name: |
        {{ pg_bin_dir }}/pg_basebackup \
          --pgdata {{ pg_data_dir }} \
          --write-recovery-conf \
          --user {{ instance.standby_config.remote_user }} \
          --host {{ instance.standby_config.remote_host }} \
          --port {{ instance.standby_config.remote_port | default(5432) }} \
          --no-password
    - runas: postgres
    - env:
      - home: {{ pg_root_dir }}
    - unless:
      - test -d {{ pg_data_dir}}
    - require:
      - file: postgresql-rootdir
      - file: pgpass file

{% else %}
  {% set initdb_params = {'datadir':'-D ' ~ pg_data_dir } %}

  {# Set default values #}
  {% for param, value in postgresql.initdb_params.items() %}
    {% do initdb_params.update({param:'--' ~ param ~ '=' ~ value }) %}
  {% endfor %}

  {# Override with instance values #}
  {% if instance.initdb_params|default(false) %}
    {% for param, value in instance.initdb_params.items() %}
      {% do initdb_params.update({param:'--' ~ param ~ '=' ~ value }) %}
    {% endfor %}
  {% endif %}

  cmd.run:
    - name:  {{ pg_bin_dir }}/initdb {{ initdb_params.values()|join(" ") }}
    - runas: postgres
    - unless:
      - test -d {{ pg_data_dir}}/base
    - require:
      - file: postgresql-rootdir
{% endif %} 

{% if instance.override_pg_hba|default(false) %}

{{ instance_name }}_postgresql-config-hba:
  file.managed:
    - name: {{ pg_data_dir }}/pg_hba.conf
    - source: salt://postgresql/files/pg_hba_entries.tmpl
    - template: jinja
    - context:
        data: {{ instance.pg_hba | default({}) | yaml }}
        override: true


{% else %}

{{ instance_name }}_postgresql-config-hba-markers:
  file.append:
    - name: {{ pg_data_dir }}/pg_hba.conf
    - text:
      - '#### SaltStack Marker Start ####'
      - '#### SaltStack Marker EOF ####'
    - require:
      - cmd: {{ instance_name }}_postgresql-initdb

{{ instance_name }}_postgresql-config-hba:
  file.blockreplace:
    - name: {{ pg_data_dir}}/pg_hba.conf
    - marker_start: '#### SaltStack Marker Start ####'
    - marker_end: '#### SaltStack Marker EOF ####'
    - source: salt://postgresql/files/pg_hba_entries.tmpl
    - template: jinja
    - context:
        data: {{ instance.pg_hba | default({}) | yaml }}
        override: false
    - require:
      - file: {{ instance_name }}_postgresql-config-hba-markers

{% endif %}

{{ instance_name }}_postgresql-main-config:
  file.append:
    - name: {{ pg_data_dir }}/postgresql.conf
    - text: |
        #------------------------------------------------------------------------------'
        # SaltStack Generated Config:
        #
        # Because this file gets included as last,
        # settings specified again in this file
        # overrule earlier definitions. 
        #------------------------------------------------------------------------------'
        include_if_exists = postgresql.conf.saltstack
    - require:
      - cmd: {{ instance_name }}_postgresql-initdb

{{ instance_name }}_postgresql-config:
  file.managed:
    - name: {{ pg_data_dir }}/postgresql.conf.saltstack
    - source: salt://postgresql/files/postgresql.conf.saltstack.tmpl
    - user: postgres
    - group: postgres
    - template: jinja
    - context:
        data: {{ instance.settings | default({}) | yaml }}
    - mode: 600
    - require:
      - file: {{ instance_name }}_postgresql-main-config

{{ instance_name }}_postgresql-config-reload:
  cmd.run:
    - name: {{ pg_bin_dir }}/pg_ctl -D {{ pg_data_dir }} reload
    - runas: postgres
    - onchanges_any:
      - file: {{ instance_name }}_postgresql-config-hba
      - file: {{ instance_name }}_postgresql-main-config
      - file: {{ instance_name }}_postgresql-config
    - onlyif:
      - {{ pg_bin_dir }}/pg_ctl -D {{ pg_data_dir }} status

{% endfor %}


