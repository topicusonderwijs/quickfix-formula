# -*- coding: utf-8 -*-
# vim: ft=yaml sw=2 ts=2 expandtab

include:
{%- if salt['state.sls_exists']('lvm') %}
  - lvm
{%- endif %}
  - dana.pgsql.pgql.repo
  - dana.pgsql.pgql.install
  - dana.pgsql.config
  - dana.pgql.environment
  - dana.pgql.scripts
  - dana.pgql.service
  - dana.pgql.roles
  - dana.pgql.databases
  - dana.pgql.extensions

