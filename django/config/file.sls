# -*- coding: utf-8 -*-
# vim: ft=sls

{# Get the 'tplroot' from tpldir' #}
{% set tplroot = tpldir.split('/')[0] %}
{%- set sls_package_install = tplroot ~ '.package.install' %}
{%- from tplroot ~ "/map.jinja" import django with context %}
{%- from tplroot ~ "/macros.jinja" import files_switch with context %}

django_user:
{%- if django.homedir_group != django.group %}
  group.present:
    - name: {{ django.homedir_group }}
{%- endif %}
  user.present:
    - name: {{ django.user }}
    - home: {{ salt['pillar.get']('users:django:home', django.home) }}
    - fullname: 'Django User'
    - shell: '/bin/bash'
    - system: True
    - require:
      - sls: {{ sls_package_install }}

django_user_home_directory:
  file.directory:
    - name: {{ django.home }}
    - user: {{ salt['pillar.get']('users:django:homedir_user', django.homedir_user) }}
    - group: {{ salt['pillar.get']('users:django:homedir_group', django.homedir_group) }}
    - mode: 750
    - require:
      - sls: {{ sls_package_install }}
      - user: django_user

django_virtualenv_directory:
  file.directory:
    - name: {{ django.venvs_dir }}
    - mode: 755
    - user: {{ django.user }}
    - group: {{ django.group }}
    - require:
      - sls: {{ sls_package_install }}
      - user: django_user

django_app_directory:
  file.directory:
    - name: {{ django.apps_dir }}
    - mode: 755
    - user: {{ django.user }}
    - group: {{ django.group }}
    - require:
      - sls: {{ sls_package_install }}
      - user: django_user

{% if 'apps' in django %}
{% for app, app_items in django.apps.items() %}
{{ app }}_git_clone:
  git.cloned:
    - name: {{ app_items.git_url }}
    - branch: {{ app_items.git_branch }}
    - target: {{ django.apps_dir }}/{{ app }}/
    - user: {{ django.user }}
    {% if 'https' in app_items %}
    - https_user: {{ https.user }}
    - https_pass: {{ https.pass }}
    {% endif %}
    - require:
      - file: django_app_directory

{{ app }}_env_file:
  file.managed:
    - name: {{ django.apps_dir }}/{{ app }}/{{ app }}.env
    - user: {{ django.user }}
    - group: {{ django.uwsgi_group }}
    - mode: 640
    - source: {{ files_switch(
                    salt['config.get'](
                        tplroot ~ ':tofs:files:django-config',
                        ['env.tmpl', 'env.tmpl.jinja']
                    )
              ) }}
    - template: jinja
    - context:
        app: {{ app|json }}
        app_items: {{ app_items|json }}
    - require:
      - git: {{ app }}_git_clone
{%- endfor -%}
{% endif %}
