PYTHON ?= python3
VENV_BIN ?= .ansiblevenv/bin
ANSIBLE_GALAXY ?= $(VENV_BIN)/ansible-galaxy
ANSIBLE_LINT ?= $(VENV_BIN)/ansible-lint
ANSIBLE_PLAYBOOK ?= $(VENV_BIN)/ansible-playbook
INVENTORY ?= inventory.ini
PLAYBOOK ?= site.yml

.PHONY: venv reset-venv install syntax-check lint check dry-run run

$(VENV_BIN)/python:
	$(PYTHON) -m venv .ansiblevenv

venv: .ansiblevenv/.deps

.ansiblevenv/.deps: $(VENV_BIN)/python Makefile
	$(VENV_BIN)/python -m pip install --upgrade pip ansible ansible-lint
	touch .ansiblevenv/.deps

reset-venv:
	$(PYTHON) -m venv --clear .ansiblevenv
	$(VENV_BIN)/python -m pip install --upgrade pip ansible ansible-lint
	touch .ansiblevenv/.deps

install: venv
	$(ANSIBLE_GALAXY) collection install -r requirements.yml

syntax-check:
	$(ANSIBLE_PLAYBOOK) -i $(INVENTORY) $(PLAYBOOK) --syntax-check

lint:
	$(ANSIBLE_LINT) $(PLAYBOOK)

check: syntax-check lint

dry-run:
	$(ANSIBLE_PLAYBOOK) -i $(INVENTORY) $(PLAYBOOK) --check --diff

run:
	$(ANSIBLE_PLAYBOOK) -i $(INVENTORY) $(PLAYBOOK)
