create.user:
  user.present:
    - name: jade
    - home: /home/jade

apache2:
  pkg.installed

/var/www/html/index.html:
  file.managed:
    - source: salt://apache/index.html
    - name: /var/www/html/index.html
    - user: jade
    - group: jade
    - mode: 644

apache2-service:
  service.running:
    - name: apache2
    - enable: True
    - watch:
      - file: /var/www/html/index.html

