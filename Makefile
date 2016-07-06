.PHONY: doc help
.DEFAULT_GOAL := help

SHELL := /usr/bin/env bash
VERSION_FILE := $(PROJECT)/version.py
VERSION := $(shell pyproject/version $(VERSION_FILE) 2> /dev/null)
IS_PYPY := $(shell pyproject/is_pypy 2> /dev/null)
NOOP := $(shell pyproject/chklib $(PROJECT) < pyproject/depends > /dev/null 2> /dev/null)
INSTALL_PACKAGE := $(PROJECT)_$(VERSION)
FAIL_UNDER := 100
TESTDIR := $(PROJECT)

export PYBUILD_DISABLE := test

all:

help:  ## Display this help
	@cat $(MAKEFILE_LIST) | grep -E '^[0-9a-zA-Z_-]+:.*?## .*$$' | sort -k1,1 | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

test_ext:

test_dep:

.requirements.txt:
	touch .requirements.txt

install: .requirements.txt  ## Standard pip install including .requirements.txt (for testing)
	pip install --upgrade -r .requirements.txt

install-edit: .requirements.txt | .deps/$(PROJECT)  ## Edit install pip install -e

test: test_dep flake8 pytest isort-check todo test_ext  ## Testing the project: flake8 pytest isort todo

isort: .deps/isort  ## Sort the headers of the project
	isort -b concurrent.futures -vb -ns "__init__.py" -sg "" -s "" -rc -p $(PROJECT) $(PROJECT)

ifeq ($(IS_PYPY),True)
isort-check:
else
isort-check: .deps/isort pytest  ## Check the isort header order (used by test)
	isort -b concurrent.futures -df -vb -ns "__init__.py" -sg "" -s "" -rc -c -p $(PROJECT) $(PROJECT)
endif

ifeq ($(IS_PYPY),True)
pytest: install-edit | .deps/hypothesis .deps/pytest .deps/pytest_cov .deps/pytest_catchlog .deps/freeze .deps/testfixtures  ## Run pytest
		py.test --doctest-modules $(TESTDIR)
else
pytest: install-edit | .deps/coverage .deps/hypothesis .deps/pytest .deps/pytest_cov .deps/pytest_catchlog .deps/freeze .deps/testfixtures
		py.test --doctest-modules --cov-report term-missing --cov=$(PROJECT) --cov-fail-under=$(FAIL_UNDER) --no-cov-on-fail $(TESTDIR)
endif

pytest-no-cov: install-edit | .deps/hypothesis .deps/pytest .deps/pytest_catchlog .deps/freeze .deps/testfixtures  ## Run pytest without coverage
	py.test --doctest-modules $(TESTDIR)

tdoc: | .deps/sphinx install-edit  ## Regenerate doc
	touch doc/*
	make -C doc html

doc: | .deps/sphinx install-edit  ## Generate doc
	make -C doc html

flake8: | .deps/flake8  ## Run flake8 test
	flake8 -j auto --ignore=E221,E222,E251,E272,E241,E203 $(PROJECT)

todo:  ## Show todos in code
	grep -Inr TODO $(PROJECT); true

merge-log: | .deps/jinja2 .deps/click  ## Create changelog -> make merge-log from=w.x to=y.z
	pyproject/genlog -m $(GIT_HUB) $(VERSION_FILE) $(from) $(to)

commit-log: | .deps/jinja2 .deps/click  ## Create changelog -> make commit-log from=w.x to=y.z
	pyproject/genlog $(GIT_HUB) $(VERSION_FILE) $(from) $(to)

clean-all:  ## Clean, ATTENTION cleans everything not in git
	@if [ -e ".git" ]; then \
		echo "Cleaning using git"; \
		git clean -df -e .vagrant -e FINJA; \
		git submodule foreach --recursive 'git clean -df -e .vagrant -e FINJA'; \
	else \
		echo "Cleaning using find" \
		find . -name "*.pyc" -delete; \
		find . -name "*.pyo" -delete; \
		find . -name "__pycache__" -delete; \
	fi

update:  ## Update submodules
	git submodule update --init --recursive

dist: clean-all update  ## Create dist for building debian packages (used by target deb)
	git checkout-index -a -f --prefix=$(INSTALL_PACKAGE)/
	git submodule foreach --recursive 'git checkout-index -a -f --prefix=${PWD}/$(INSTALL_PACKAGE)$${toplevel#${PWD}}/$$path/'
	make log
	cp debian/changelog $(INSTALL_PACKAGE)/debian/changelog
	cp CHANGELOG.rst $(INSTALL_PACKAGE)/CHANGELOG.rst
	tar cfz ../$(INSTALL_PACKAGE).orig.tar.gz $(INSTALL_PACKAGE)
	rm -rf $(INSTALL_PACKAGE)

log: | .deps/jinja2 .deps/click .deps/dateutil  ## Create log for packages (git add and git commit needed!)
	pyproject/genchangelog $(PROJECT) CHANGELOG debian/changelog CHANGELOG.rst

deb: dist  ## Build a debian
	sudo apt-get install -y  build-essential devscripts equivs
	mk-build-deps
	sudo dpkg -i *.deb
	rm -rf *.deb
	dpkg-buildpackage -us -uc

rpm:  ## Build a rpm package
	python setup.py bdist_rpm

pypi:  ## Release package to pypi
	python setup.py sdist upload -s

.deps/$(PROJECT):
	pip install --upgrade -r .requirements.txt -e .

.deps/pytest_catchlog:
	pip install --upgrade pytest-catchlog

.deps/isort:
	pip install --upgrade isort
	@pyenv rehash > /dev/null 2> /dev/null; true

.deps/flake8:
	pip install --upgrade flake8
	@pyenv rehash > /dev/null 2> /dev/null; true

.deps/pytest:
	pip install --upgrade pytest
	@pyenv rehash > /dev/null 2> /dev/null; true

.deps/pytest_cov:
	pip install --upgrade pytest-cov

.deps/sphinx: | .deps/sphinx_rtd_theme
	pip install --upgrade sphinx
	@pyenv rehash > /dev/null 2> /dev/null; true

.deps/sphinx_rtd_theme:
	pip install --upgrade sphinx_rtd_theme

.deps/hypothesis: | .deps/hypothesispytest
	pip install --upgrade hypothesis

.deps/hypothesispytest:
	pip install --upgrade hypothesis-pytest

.deps/freeze:
	pip install --upgrade freeze

.deps/testfixtures:
	pip install --upgrade testfixtures

.deps/coverage:
	pip install --upgrade coverage
	@pyenv rehash > /dev/null 2> /dev/null; true

.deps/jinja2:
	pip install --upgrade jinja2

.deps/click:
	pip install --upgrade click

.deps/dateutil:
	pip install --upgrade python-dateutil

.deps/cffi:
	pip install --upgrade cffi
