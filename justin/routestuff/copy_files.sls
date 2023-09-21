/root/delete_old_routes.sh:
  file.managed:
    - source: salt://quickfix/justin/routestuff/delete_old_routes.sh
    - owner: root
    - group: root
    - mode: 750

