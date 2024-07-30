# -*- coding: utf-8 -*-
# vim: ft=yaml sw=2 ts=2 expandtab

include:
{%- if salt['state.sls_exists']('lvm') %}
  - lvm
{%- endif %}
  - postgresql.repo
  - postgresql.install
  - postgresql.config
  - postgresql.environment
  - postgresql.scripts
  - postgresql.service
  - postgresql.roles
  - postgresql.databases
  - postgresql.extensions

