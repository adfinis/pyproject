=====================
Releasing a PyProject
=====================

Releasing is a semi-automatic process. You have to edit some files and GitLab-CI
will do the rest.

Version
=======

Edit the version in $(PROJECT)/version.py

Changelog
=========

You can either generate a pull-request based changelog.

.. code-block:: bash

   make merge-log from=w.x to=y.z

It will generate a CHANGELOG entry, please prepend that entry to the CHANGLOG
file and edit it as you wish.

You can also generate a commit based changelog.

.. code-block:: bash

   make commit-log from=w.x to=y.z

from/to usually are git-tags, but it can be anything git recognizes.

Then generate the actual changelog files:

.. code-block:: bash

   make log
   git add -p
   git commit -m "Bumped version and updated changelog"

Testing
=======

.. code-block:: bash

   make deb

Will create a debian package for the debian or ubuntu version you call this on.

.. code-block:: bash

   make rpm

Will create a rpm package for the RedHat or Suse version you call this on.
