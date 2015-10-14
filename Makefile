SHELL := /usr/bin/env bash

HAS_FLAKE8     := $(shell pyproject/chklib flake8)
HAS_COVERAGE   := $(shell pyproject/chklib coverage)
HAS_SPHINX     := $(shell pyproject/chklib sphinx)
HAS_NOSETESTS  := $(shell pyproject/chklib nose)
HAS_PYTEST     := $(shell pyproject/chklib pytest)
HAS_PYTEST_COV := $(shell pyproject/chklib pytest_cov)
HAS_FREEZE     := $(shell pyproject/chklib freeze)
HAS_HYPOTHESIS := $(shell pyproject/chklib hypothesis)
HAS_CAPTURELOG := $(shell pyproject/chklib pytest_capturelog)
HAS_ISORT      := $(shell pyproject/chklib isort)

all:

test_ext:

.requirements.txt:
	touch .requirements.txt

install: .requirements.txt
	pip install --upgrade -r .requirements.txt .

install-edit: .requirements.txt $(PROJECT).egg-info

$(PROJECT).egg-info:
	pip install --upgrade -r .requirements.txt -e .

test: flake8 isort-check pytest todo test_ext

isort:
	isort -vb -ns "__init__.py" -sg "" -s "" -rc $(PROJECT)

isort-check: $(HAS_ISORT)
	isort -vb -ns "__init__.py" -sg "" -s "" -rc -c $(PROJECT)

nosetest: install-edit $(HAS_COVERAGE) $(HAS_HYPOTHESIS) $(HAS_NOSETESTS) $(HAS_FREEZE)
	nosetests --cover-package=$(PROJECT) --with-coverage --cover-tests --cover-erase --cover-min-percentage=100

pytest: install-edit $(HAS_COVERAGE) $(HAS_HYPOTHESIS) $(HAS_PYTEST) $(HAS_PYTEST_COV) $(HAS_FREEZE) $(HAS_CAPTURELOG)
	py.test --cov-report term-missing --cov=$(PROJECT) --cov-fail-under=100 --no-cov-on-fail $(PROJECT)

$(HAS_CAPTURELOG):
	pip install --upgrade pytest-capturelog

$(HAS_NOSETESTS):
	pip install --upgrade nose
	@pyenv rehash > /dev/null 2> /dev/null; true

$(HAS_ISORT):
	pip install --upgrade isort
	@pyenv rehash > /dev/null 2> /dev/null; true

$(HAS_FLAKE8):
	pip install --upgrade flake8
	pip install --upgrade pyflakes
	@pyenv rehash > /dev/null 2> /dev/null; true

$(HAS_PYTEST):
	pip install --upgrade pytest
	@pyenv rehash > /dev/null 2> /dev/null; true

$(HAS_PYTEST_COV):
	pip install --upgrade pytest-cov

$(HAS_SPHINX):
	pip install --upgrade sphinx
	pip install --upgrade sphinx_rtd_theme
	@pyenv rehash > /dev/null 2> /dev/null; true

$(HAS_HYPOTHESIS):
	pip install --upgrade hypothesis
	pip install --upgrade hypothesis-pytest

$(HAS_FREEZE):
	pip install --upgrade freeze

$(HAS_COVERAGE):
	pip install --upgrade coverage
	@pyenv rehash > /dev/null 2> /dev/null; true

doc: $(HAS_SPHINX) install-edit
	make -C doc html

flake8: $(HAS_FLAKE8)
	flake8 --doctests -j auto --ignore=E221,E222,E251 $(PROJECT)

todo:
	grep -Inr TODO $(PROJECT)
