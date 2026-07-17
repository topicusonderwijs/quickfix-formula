
{% from "github-runner/map.jinja" import githubrunner with context -%}

{% set version = githubrunner['actions-runner'].version %}
{% set hash = githubrunner['actions-runner'].hash %}


github-runner:
  user.present:
    - system: true
    - usergroup: true
    - home: /opt/github-runner
    - password_lock: true


/opt/github-runner/actions-runner:
  archive.extracted:
    - source: https://github.com/actions/runner/releases/download/v{{ version }}/actions-runner-linux-x64-{{ version }}.tar.gz
    - source_hash: sha256={{ hash }}
    - user: github-runner
    - group: github-runner
    - unless: cat /opt/github-runner/actions-runner/svc.sh


config-actions-runner:
  cmd.run:
    - name: "./config.sh --url \"${GHR_URL}\" --token \"${GHR_TOKEN}\" --unattended --replace"
    - runas: github-runner
    - cwd: /opt/github-runner/actions-runner
    - env:
        GHR_URL: "{{ githubrunner['actions-runner'].url }}"
        GHR_TOKEN: "{{ githubrunner['actions-runner'].token }}"
    - unless: cat /opt/github-runner/actions-runner/svc.sh

service-actions-runner:
  cmd.run:
    - name: "./svc.sh install github-runner && ./svc.sh start"
    - runas: root
    - cwd: /opt/github-runner/actions-runner
