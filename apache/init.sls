create.user:
  user.present:
    - name: jade
    - home: /home/jade

apache2:
  pkg.installed

/var/www/html:
  file.recurse:
    - source: salt://apache
    - user: jade
    - group: jade
    - file_mode: 644
    - dir_mode: 755

apache2-service:
  service.running:
    - name: apache2
    - enable: True
    - watch:
      - file: /var/www/html

