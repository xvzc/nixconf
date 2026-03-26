SHELL := /bin/sh
MAKEFLAGS += --no-print-directory

CACHE_DIR := .cache

HOSTS := \
  macbook-air-m2 \
  nixos-desktop-01 \
  nixos-desktop-02 \
  quit

UNAME := $(shell uname)
HOST := $(shell hostname)

ifeq ($(UNAME), Darwin)
INSTALL_COMMAND := sh .cache/install.sh
else
INSTALL_COMMAND := sh .cache/install.sh --daemon
endif

# ┌──────────────┐ 
# │ INIT PROJECT │ 
# └──────────────┘ 
init: $(CACHE_DIR)/ran-setup

$(CACHE_DIR)/current-host:
	$(MAKE) _select-current-host

$(CACHE_DIR)/has-nix: | $(CACHE_DIR)/current-host
	$(MAKE) _check-or-install-nix
	@touch $(CACHE_DIR)/has-nix

$(CACHE_DIR)/ran-setup: | $(CACHE_DIR)/has-nix
	$(MAKE) _setup
	@touch $(CACHE_DIR)/ran-setup

_select-current-host:
	@$(MAKE) _info MSG="Select a host:"
	@select SELECTION in ${HOSTS}; do \
		if [ "$$SELECTION" = "quit" ]; then \
			$(MAKE) _info MSG="Quit"; \
			exit 1; \
		elif [ -n "$$SELECTION" ]; then \
			CURRENT_HOST="$$SELECTION"; \
			break; \
		else \
			$(MAKE) _error MSG="Invalid selection"; \
			exit 1; \
		fi; \
	done; \
	$(MAKE) _info MSG="Selected host: is '$$CURRENT_HOST'"; \
	mkdir -p $(CACHE_DIR); \
	echo "$$CURRENT_HOST" > $(CACHE_DIR)/current-host

_check-or-install-nix:
	@if command -v nix >/dev/null 2>&1; then \
		$(MAKE) _info MSG="Found a nix binary at '$$(which nix)'"; \
	else \
		$(MAKE) _info MSG="NIX binary is not found"; \
		curl --proto '=https' --tlsv1.2 -L -o $(CACHE_DIR)/install.sh https://nixos.org/nix/install; \
		$(INSTALL_COMMAND); \
	fi

_setup:
ifeq ($(UNAME), Darwin)
	CURRENT_HOST=$(shell cat $(CACHE_DIR)/current-host); \
    . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'; \
	caffeinate -ids nix build \
		--extra-experimental-features nix-command \
		--extra-experimental-features flakes \
		".#darwinConfigurations.$$CURRENT_HOST.system" \
		&& sudo ./result/sw/bin/darwin-rebuild switch --flake ".#$$CURRENT_HOST";
else
	CURRENT_HOST=$(shell cat $(CACHE_DIR)/current-host); \
	sudo NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 nixos-rebuild switch \
		--flake ".#$$CURRENT_HOST";
endif

# ┌─────────────────────┐ 
# │ UPDATE FLAKE INPUTS │ 
# └─────────────────────┘ 
update: 
	nix flake update assets nvim

# ┌───────────────┐ 
# │ CLEAN PROJECT │ 
# └───────────────┘ 
clean: 
	@rm -rf $(CACHE_DIR)
	@$(MAKE) _info MSG="Cleaned cache"

_info:
	@echo "[\033[0;32m\033[1mINFO\033[0m] $(MSG)"

_error:
	@echo "[\033[0;31m\033[1mERROR\033[0m] $(MSG)"
	@exit 1

