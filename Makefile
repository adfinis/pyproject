.PHONY: doc

SHELL := /usr/bin/env bash
VERSION_FILE := $(PROJECT)/version.py
VERSION := $(shell pyproject/version $(VERSION_FILE))
IS_PYPY := $(shell pyproject/is_pypy)
NOOP := $(shell pyproject/chklib $(PROJECT) < pyproject/depends)
INSTALL_PACKAGE := $(PROJECT)_$(VERSION)
FAIL_UNDER := 100

export PYBUILD_DISABLE := test

all:

test_ext:

test_dep:

.requirements.txt:
	touch .requirements.txt

install: .requirements.txt
	pip install --upgrade -r .requirements.txt

install-edit: .requirements.txt | .deps/$(PROJECT)

test: test_dep flake8 pytest isort-check todo test_ext

isort:
	isort -b concurrent.futures -vb -ns "__init__.py" -sg "" -s "" -rc -p $(PROJECT) $(PROJECT)

ifeq ($(IS_PYPY),True)
isort-check:
else
isort-check: .deps/isort pytest
	isort -b concurrent.futures -df -vb -ns "__init__.py" -sg "" -s "" -rc -c -p $(PROJECT) $(PROJECT)
endif

ifeq ($(IS_PYPY),True)
pytest: install-edit | .deps/coverage .deps/hypothesis .deps/pytest .deps/pytest_cov .deps/pytest_catchlog .deps/freeze .deps/testfixtures
		py.test --doctest-modules $(PROJECT)
else
pytest: install-edit | .deps/coverage .deps/hypothesis .deps/pytest .deps/pytest_cov .deps/pytest_catchlog .deps/freeze .deps/testfixtures
		py.test --doctest-modules --cov-report term-missing --cov=$(PROJECT) --cov-fail-under=$(FAIL_UNDER) --no-cov-on-fail $(PROJECT)
endif

pytest-no-cov: install-edit | .deps/hypothesis .deps/pytest .deps/pytest_catchlog .deps/freeze .deps/testfixtures
	py.test --doctest-modules $(PROJECT)

tdoc: | .deps/sphinx install-edit
	touch doc/*
	make -C doc html

doc: | .deps/sphinx install-edit
	make -C doc html

flake8: | .deps/flake8
	flake8 -j auto --ignore=E221,E222,E251,E272,E241,E203 $(PROJECT)

todo:
	grep -Inr TODO $(PROJECT); true

merge-log: | .deps/jinja2 .deps/click
	pyproject/genlog -m $(GIT_HUB) $(VERSION_FILE) $(from) $(to)

commit-log: | .deps/jinja2 .deps/click
	pyproject/genlog $(GIT_HUB) $(VERSION_FILE) $(from) $(to)

clean:
	@if [ -e ".git" ]; then \
		echo "Cleaning using git"; \
		git clean -xdf -e .vagrant; \
		git submodule foreach --recursive 'git clean -xdf -e .vagrant'; \
	else \
		echo "Cleaning using find" \
		find . -name "*.pyc" -delete; \
		find . -name "*.pyo" -delete; \
		find . -name "__pycache__" -delete; \
	fi

update:
	git submodule update --init --recursive

dist: clean update
	git checkout-index -a -f --prefix=$(INSTALL_PACKAGE)/
	git submodule foreach --recursive 'git checkout-index -a -f --prefix=${PWD}/$(INSTALL_PACKAGE)$${toplevel#${PWD}}/$$path/'
	tar cfz ../$(INSTALL_PACKAGE).orig.tar.gz $(INSTALL_PACKAGE)
	rm -rf $(INSTALL_PACKAGE)

log: | .deps/jinja2 .deps/click .deps/dateutil
	pyproject/genchangelog $(PROJECT) CHANGELOG debian/changelog CHANGELOG.rst

deb: dist
	dpkg-checkbuilddeps 2>&1 | cut -d ":" -f 3 | xargs sudo apt-get -y install
	dpkg-buildpackage -us -uc

rpm:
	python setup.py bdist_rpm

pypi:
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
