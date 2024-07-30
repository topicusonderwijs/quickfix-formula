# vim: ts=2 sw=2 sts=2 expandtab filetype=yaml
{% from "postgresql/map.jinja" import postgresql with context %}

postgresql-environment-pager-package:
  pkg.installed:
    - name: pspg

postgresql-environment-pgsql-profile:
  file.managed:
    - name: /var/lib/pgsql/.pgsql_profile
    - user: postgres
    - group: postgres
    - mode: 640
    - source: salt://postgresql/files/pgsql_profile
    - require:
      - file: postgresql-rootdir

postgresql-environment-psqlrc:
  file.managed:
    - name: /var/lib/pgsql/.psqlrc
    - user: postgres
    - group: postgres
    - mode: 640
    - source: salt://postgresql/files/psqlrc
    - require:
      - file: postgresql-rootdir

postgresql-environment-pspgconf:
  file.managed:
    - name: /var/lib/pgsql/.pspgconf
    - user: postgres
    - group: postgres
    - mode: 640
    - source: salt://postgresql/files/pspgconf
    - require:
      - file: postgresql-rootdir

