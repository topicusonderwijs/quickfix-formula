
{% set version="2.311.0" %}
{% set hash="29fc8cf2dab4c195bb147384e7e2c94cfd4d4022c793b346a6175435265aa278" %}



github-runner:
  user.present:
    - system: true
    - usergroup: true
    - home: /opt/github-runner
    - password_lock: true


/opt/github-runner/actions-runner:
  archive.extracted:
    - source: https://github.com/actions/runner/releases/download/v{{ version }}/actions-runner-linux-x64-{{ version }}.tar.gz
    - source_hash: {{ hash }}
    - user: github-runner
    - group: github-runner


config-actions-runner:
  cmd.run:
    - name: "./config.sh --url $GHR_URL --token $GHR_TOKEN"
    - user: github-runner
    - group: github-runner
    - cwd: /opt/github-runner/actions-runner
    - env:
        GHR_URL: "{{ salt['pillar.get']('githubrunner.actions-runner.url','None') }}"
        GHR_TOKEN:   "{{ salt['pillar.get']('githubrunner.actions-runner.token','None') }}"

