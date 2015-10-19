==========
Py Project
==========

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

* If you want to disable a standard dependency create a file .no* your project
  root, for example to disable pytest_capturelog .nopytest_capturelog.
