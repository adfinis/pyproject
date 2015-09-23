==========
Py Project
==========

To use this:

pylint must be installed in the system or a global python environment.

Contains common files, like

* Makefile
* pylintrc
* A template for setup.py

Dependencies
============

Some dependencies are only used for old python compatibility for example mock.
If you don't want mock to be installed create a file called .nomock in the root
of your project. See the Makefile for library names that are installed. This
works for any of those.
