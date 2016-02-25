SHELL := /usr/bin/env bash

NOOP := $(shell pyproject/chklib $(PROJECT) < pyproject/depends)

all:

test_ext:

.requirements.txt:
	touch .requirements.txt

install: .requirements.txt
	pip install --upgrade -r .requirements.txt .

install-edit: .requirements.txt .deps/$(PROJECT)

.deps/$(PROJECT):
	pip install --upgrade -r .requirements.txt -e .

test: flake8 isort-check pytest todo test_ext

isort:
	isort -vb -ns "__init__.py" -sg "" -s "" -rc $(PROJECT)

isort-check: .deps/isort
	isort -vb -ns "__init__.py" -sg "" -s "" -rc -c $(PROJECT)

nosetest: install-edit .deps/coverage .deps/hypothesis .deps/nose .deps/freeze .deps/testfixtures
	nosetests --cover-package=$(PROJECT) --with-coverage --cover-tests --cover-erase --cover-min-percentage=100

pytest: install-edit .deps/coverage .deps/hypothesis .deps/pytest .deps/pytest_cov .deps/pytest_catchlog .deps/freeze .deps/testfixtures
	py.test --cov-report term-missing --cov=$(PROJECT) --cov-fail-under=100 --no-cov-on-fail $(PROJECT)

tdoc: .deps/sphinx install-edit
	touch doc/*
	make -C doc html

doc: .deps/sphinx install-edit
	make -C doc html

flake8: .deps/flake8
	flake8 -j auto --ignore=E221,E222,E251 $(PROJECT)

todo:
	grep -Inr TODO $(PROJECT); true

.deps/pytest_catchlog:
	pip install --upgrade pytest-catchlog

.deps/nose:
	pip install --upgrade nose
	@pyenv rehash > /dev/null 2> /dev/null; true

.deps/isort:
	pip install --upgrade isort
	@pyenv rehash > /dev/null 2> /dev/null; true

.deps/flake8:
	pip install --upgrade flake8
	pip install --upgrade pyflakes
	@pyenv rehash > /dev/null 2> /dev/null; true

.deps/pytest:
	pip install --upgrade pytest
	@pyenv rehash > /dev/null 2> /dev/null; true

.deps/pytest_cov:
	pip install --upgrade pytest-cov

.deps/sphinx: .deps/sphinx_rtd_theme
	pip install --upgrade sphinx
	@pyenv rehash > /dev/null 2> /dev/null; true

.deps/sphinx_rtd_theme:
	pip install --upgrade sphinx_rtd_theme

.deps/hypothesis: .deps/hypothesispytest
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

