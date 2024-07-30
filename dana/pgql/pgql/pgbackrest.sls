# -*- coding: utf-8 -*-
# vim: ft=yaml sw=2 ts=2 expandtab
{% from "postgresql/map.jinja" import postgresql with context %}
{% from "postgresql/_macros/pgbackrest.jinja" import gen_cron_config with context %}

install pgbackrest:
  pkg.installed:
    - name: pgbackrest

pgbackrest spool dir:
  file.directory:
    - name: /var/spool/pgbackrest
    - user: postgres
    - group: postgres
    - mode: 750

pgbackrest etc:
  file.directory:
    - name: /etc/pgbackrest
    - user: postgres
    - group: postgres
    - mode: 750

pgbackrest configuration:
  file.managed:
    - name: /etc/pgbackrest.conf
    - user: postgres
    - group: postgres
    - mode: 640
    - template: jinja
    - source: salt://postgresql/files/pgbackrest.conf.jinja
    - context:
        data: {{ postgresql | yaml }}


{%- for repo in postgresql.pgbackrest.repositories %}

{%- if repo.type == "gcs" and repo["gcs-key"] is defined %}
pgbackrest repo-{{loop.index}}-key:
  file.managed:
    - name: /etc/pgbackrest/gcs-key-repo-{{loop.index}}.json
    - user: postgres
    - group: postgres
    - mode: 640
    - contents: {{ repo["gcs-key"] | json }}

{%- endif %}

{%- endfor %}

{%- for instance, values in postgresql.instance.items() %}
{%- if not values.pgbackrest | default(False) %}
{%- do values.update({'pgbackrest': {}}) %}
{%- endif %}
{%- if (values.pgbackrest.enabled | default(True)) and (values.pgbackrest.create_stanza | default(false)) %}
{%- set stanzaName = values.pgbackrest.stanza | default(instance) %}

pgbackrest stanza create / {{ stanzaName }}:
  cmd.run:
    - name: /usr/bin/pgbackrest --stanza={{ stanzaName }} stanza-create
    - runas: postgres
    - onchanges:
      - file: pgbackrest configuration

{#
 # The macro "gen_cron_config" creates the yaml for the cron state(s) depending on the
 # profile name (eg. daily_full, weekly_full_daily_incr).
 #
 # See pillar.example for the configuration opions of "postgresql:instance:<name>:pgbackrest:cron"
#} 
{%- set cron_config = values.pgbackrest.cron | default({}) %}
{{ gen_cron_config(stanzaName, cron_config) }}
{%- endif %}
{%- endfor %}



