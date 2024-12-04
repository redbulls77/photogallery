create_images_directory:
  file.directory:
    - name: /var/www/html/images
    - user: jade
    - group: jade
    - mode: 755

download_image_1:
  file.managed:
    - name: /var/www/html/images/1.JPEG
    - source: https://raw.githubusercontent.com/redbulls77/kuvat/main/1.JPEG
    - skip_verify: True
    - user: jade
    - group: jade
    - mode: 644

download_image_2:
  file.managed:
    - name: /var/www/html/images/2.JPEG
    - source: https://raw.githubusercontent.com/redbulls77/kuvat/main/2.JPEG
    - skip_verify: True
    - user: jade
    - group: jade
    - mode: 644

download_image_3:
  file.managed:
    - name: /var/www/html/images/3.JPEG
    - source: https://raw.githubusercontent.com/redbulls77/kuvat/main/3.JPEG
    - skip_verify: True
    - user: jade
    - group: jade
    - mode: 644

download_image_4:
  file.managed:
    - name: /var/www/html/images/4.JPEG
    - source: https://raw.githubusercontent.com/redbulls77/kuvat/main/4.JPEG
    - skip_verify: True
    - user: jade
    - group: jade
    - mode: 644
