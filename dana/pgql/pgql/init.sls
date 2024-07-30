# -*- coding: utf-8 -*-
# vim: ft=yaml sw=2 ts=2 expandtab

include:
{%- if salt['state.sls_exists']('lvm') %}
  - lvm
{%- endif %}
  - pgql.repo
  - pgql.install
  - pgql.config
  - pgql.environment
  - pgql.scripts
  - pgql.service
  - pgql.roles
  - pgql.databases
  - pgql.extensions

