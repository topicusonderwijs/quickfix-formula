{% from "postgresql/map.jinja" import postgresql with context %}

{% if postgresql.scripts %}

{% set script_cfg = postgresql.scripts %}
{% set pg_scripts_dir = postgresql.root_dir + '/scripts' %}
jq:
  pkg:
    - installed


postgresql-scriptsdir:
  file.directory:
    - name: {{ pg_scripts_dir }}
    - mode: 700
    - user: postgres
    - group: postgres

postgresql-scripts_basefunctions:
  file.managed:
    - name: {{ pg_scripts_dir }}/base_functions.sh
    - source: salt://postgresql/files/scripts/base_functions.sh.j2
    - user: postgres
    - group: postgres
    - template: jinja
    - context:
        add_cleanup: {{ script_cfg.add_cleanup | default(False) | yaml }}
    - mode: 600

postgresql-scripts_pg_upgrade:
  file.managed:
    - name: {{ pg_scripts_dir }}/pg_upgrade.sh
    - source: salt://postgresql/files/scripts/pg_upgrade.sh.j2
    - user: postgres
    - group: postgres
    - template: jinja
    - mode: 770


postgresql-scripts_secrets:
  file.managed:
    - name: {{ pg_scripts_dir }}/.secrets
    - source: salt://postgresql/files/scripts/secrets.j2
    - user: postgres
    - group: postgres
    - template: jinja
    - context:
        secrets: {{ script_cfg.secrets | default({}) | yaml }}
    - mode: 600

{% if script_cfg.files is defined %} 
{% for filename, content in script_cfg.files.items() %}

postgresql-scripts-file-{{filename}}:
  file.managed:
    - name: {{ pg_scripts_dir }}/{{filename}}
{%- if content.startswith('salt://') %}
    - source: {{content}}
{%- else %}
    {# This will copy pillar content to the file without the possible problems of putting the text in the state #}
    - contents_pillar: postgresql:scripts:files:{{filename}}
{%- endif %}
    - user: postgres
    - group: postgres
    - mode: 770

{% endfor %}
{% endif %}

{% endif %}
