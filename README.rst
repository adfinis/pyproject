==========
Py Project
==========

Add this as a submodule to your project:

.. code-block:: bash

   git submodule add pyproject https://github.com/adfinis-sygroup/pyproject

Contains common files, like

* Makefile
* A template for setup.py

It expects that you are using virtualenv and/or pyenv.

Makefile
========

Create the following Makefile in your project:

.. code-block:: Makefile

   PROJECT := [project-package-dir]

   include pyproject/Makefile

   test_ext:
      echo Execute custom tests

Dependencies
============

* If you need additional dependencies for tests add them to .requirments.txt in the
  project.
