==========
Py Project
==========

|License|

.. |License| image:: https://img.shields.io/github/license/adfinis-sygroup/pyproject.svg?style=flat-square
   :target: LICENSE

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

Contributions
=============

Contributions are more than welcome! Please feel free to open new issues or
pull requests.

License 
=======

GNU GENERAL PUBLIC LICENSE Version 3

See the `LICENSE`_ file.

.. _LICENSE: LICENSE
