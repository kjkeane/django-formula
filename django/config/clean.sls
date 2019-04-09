# -*- coding: utf-8 -*-
# vim: ft=sls

{# Get the 'tplroot' from tpldir' #}
{% set tplroot = tpldir.split('/')[0] %}
{%- set sls_package_install = tplroot ~ '.package.install' %}
{%- from tplroot ~ "/map.jinja" import django with context %}
{%- from tplroot ~ "/macros.jinja" import files_switch with context %}

django_user_absent:
  user.absent:
    - name: {{ django.user }}
    - purge: True

django_user_home_directory:
  file.absent:
    - name: {{ django.home }}
    - require:
      - user: django_user_absent

django_virtualenv_directory_absent:
  file.absent:
    - name: {{ django.venvs_dir }}

django_app_directory_absent:
  file.absent:
    - name: {{ django.apps_dir }}

{% if 'apps' in django %}
{% for app, app_items in django.apps.items() %}
{{ app }}_env_file_absent:
  file.absent:
    - name: {{ django.apps_dir }}/{{ app }}/{{ app }}.env
{%- endfor -%}
{% endif %}
