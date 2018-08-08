===========================================================================
Deprecated please use pipenv_, stdeb_, compose_ and meson_ for new projects
===========================================================================

.. _stdeb: https://pypi.org/project/stdeb/
.. _pipenv: https://github.com/pypa/pipenv
.. _compose: https://docs.docker.com/compose/
.. _meson: https://mesonbuild.com/

|
|
|
|
|
|
|
|
|
|
|
|
|
|
|
|
|
|
|
|
|
|
|
|
|
|
|
|
|
|
|
|
|
|
|
|
|
|
|
|
|
|
|
|
|
|
|
|
|
|
|
|

==========
Py Project
==========

Add this as a submodule to your project:

.. code-block:: bash

   git submodule add https://github.com/adfinis-sygroup/pyproject

Contains common files, like

* Makefile
* A template for setup.py

It expects that you are using virtualenv and/or pyenv.

Makefile
========

Create the following Makefile in your project:

.. code-block:: Makefile

   PROJECT := [project-package-dir]
   GIT_HUB := https://[github-or-gitlab-url]

   include pyproject/Makefile

   test_ext:
      echo Execute custom tests
      
   my_custom_pytest: .deps/pytest
      py.test .....

Dependencies
============

* If you need defined dependencies for tests add them to test_dep, like so:

.. code-block:: Makefile

   test_dep: .deps/jinja2 my_custom_cextension

* If you need additional dependencies for tests add them to .requirments.txt in the
  project.

Docker helper
=============

Standard docker tasks

.. code-block:: Makefile

   include pyproject/docker.mk

Usage
-----

.. code-block:: text

   clean-containers               Remove old docker containers
   clean-docker                   Remove all docker containers and dangling images
   clean-image                    Remove the working docker image
   docker-run                     Run default command in docker
   image                          Build the image
   root-shell                     Open a root-shell in container
   shell                          Open a shell in a container

Config
------

Define the following variables

.. code-block:: Makefile

   DOCKER_DIR  := docker
   IMAGE_NAME  := myproject
   DEFAULT_CMD := cd /host && make test

Create DOCKER_DIR/Dockerfile

Execute hid.sh in your Dockerfile. It should work for Redhat and Debian. If it
doesn't work do the equivalent of hid.sh.

hid.sh is a helper to create the current user inside the container, so the
commands don't run as root.

Example Dockerfile
------------------

.. code-block:: bash

   FROM debian:jessie
   ADD * /install/
   RUN /install/hid.sh
