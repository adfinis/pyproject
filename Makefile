SHELL := /usr/bin/env bash

HAS_PEP8       := $(shell pyproject/chklib pep8)
HAS_PYLINT     := $(abspath $(shell which pylint || echo nopylint))
HAS_COVERAGE   := $(shell pyproject/chklib coverage)
HAS_SPHINX     := $(shell pyproject/chklib sphinx)
HAS_NOSETESTS  := $(shell pyproject/chklib nose)
HAS_PYTEST     := $(shell pyproject/chklib pytest)
HAS_PYTEST_COV := $(shell pyproject/chklib pytest_cov)
HAS_FREEZE     := $(shell pyproject/chklib freeze)
HAS_HYPOTHESIS := $(shell pyproject/chklib hypothesis)
HAS_MOCK       := $(shell pyproject/chklib mock)

all:

install:
	pip install --upgrade .

install-edit: $(PROJECT).egg-info

$(PROJECT).egg-info:
	pip install --upgrade -e .

test: pep8 pylint pytest todo

nosetest: $(HAS_COVERAGE) $(HAS_HYPOTHESIS) $(HAS_NOSETESTS) $(HAS_FREEZE) $(HAS_MOCK)
	nosetests --cover-package=$(PROJECT) --with-coverage --cover-tests --cover-erase --cover-min-percentage=100

pytest: $(HAS_COVERAGE) $(HAS_HYPOTHESIS) $(HAS_PYTEST) $(HAS_PYTEST_COV) $(HAS_FREEZE) $(HAS_MOCK)
	py.test --cov-report term-missing --cov=$(PROJECT) --cov-fail-under=100 --no-cov-on-fail $(PROJECT)

$(HAS_NOSETESTS):
	pip install --upgrade nose
	@pyenv rehash > /dev/null 2> /dev/null; true

$(HAS_PYTEST):
	pip install --upgrade pytest
	@pyenv rehash > /dev/null 2> /dev/null; true

$(HAS_PYTEST_COV):
	pip install --upgrade pytest-cov

$(HAS_MOCK):
	pip install --upgrade mock

$(HAS_SPHINX):
	pip install --upgrade sphinx
	pip install --upgrade sphinx_rtd_theme
	@pyenv rehash > /dev/null 2> /dev/null; true

$(HAS_HYPOTHESIS):
	pip install --upgrade hypothesis

$(HAS_FREEZE):
	pip install --upgrade freeze

$(HAS_PEP8):
	pip install --upgrade pep8
	@pyenv rehash > /dev/null 2> /dev/null; true

$(HAS_PYLINT):
	pip install --upgrade pylint
	@pyenv rehash > /dev/null 2> /dev/null; true

$(HAS_COVERAGE):
	pip install --upgrade coverage
	@pyenv rehash > /dev/null 2> /dev/null; true

doc: $(HAS_SPHINX) install-edit
	make -C doc html

pep8: $(HAS_PEP8)
	pep8 --ignore=E203,E272,E221,W291,E251,E203,E501,E402,E241 $(PROJECT)

pylint: $(HAS_PYLINT)
	pylint --disable=fixme -r n $(PROJECT) --msg-template "{path} {C}:{line:3d},{column:2d}: {msg} ({symbol})"

todo: $(HAS_PYLINT)
	pylint --disable=all --enable=fixme -r n $(PROJECT) --msg-template "{path} {C}:{line:3d},{column:2d}: {msg} ({symbol})"; true
