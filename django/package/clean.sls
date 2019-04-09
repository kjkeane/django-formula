# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import django with context %}

django-packages-pkg-removed:
  pkg.removed:
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

django-epel-packages-pkg-removed:
  pkg.removed:
    - pkgs:
      - python2-pip
      - python36-devel
      - python36-pip
