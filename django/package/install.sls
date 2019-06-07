# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import django with context %}

{%- if grains[os_family'] == 'RedHat' and upstream-repo %}
django-epel-release:
  pkg.installed:
    - name: epel-release
{%- endif %}

django-packages-pkg-installed:
  pkg.installed:
    - pkgs:
      - git
      - gcc
      - libxslt-devel
      - openldap-devel
      - openssl-devel
      - python-devel
      - python-virtualenv
      - readline-devel
      - zlib-devel

django-epel-packages-pkg-installed:
  pkg.installed:
    - pkgs:
      - python2-pip
      - python36-devel
      - python36-pip
{%- if grains['os_family'] == 'RedHat' and upstream-repo %}
    - require:
      - pkg: django-epel-release
{%- endif %}
