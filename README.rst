==========
Py Project
==========

Contains common files, like

* Makefile
* A template for setup.py

Dependencies
============

Some dependencies are only used for old python compatibility for example mock.
If you don't want mock to be installed create a file called .nomock in the root
of your project. See the Makefile for library names that are installed. This
works for any of those.
