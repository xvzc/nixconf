SHELL := /bin/sh

HOSTS := \
  macbook-air-m2 \
  nixos-desktop-01 \
  nixos-desktop-02 \
  quit

UNAME := $(shell uname)

ifeq ($(UNAME), Darwin)
INSTALL_COMMAND := .cache/install.sh
else
INSTALL_COMMAND := .cache/install.sh --daemon
endif

clean: 
	@rm -rf .cache
	@echo "Cleaned cache\n"

init: .cache/ran-setup

.cache/current-host:
	$(MAKE) select-current-host

.cache/has-nix: | .cache/current-host
	$(MAKE) check-or-install-nix
	@touch .cache/has-nix

.cache/ran-setup: | .cache/has-nix
	$(MAKE) setup
	@touch .cache/ran-setup

select-current-host:
	@echo "Select a host:"
	@select SELECTION in ${HOSTS}; do \
		if [ "$$SELECTION" = "quit" ]; then \
			echo "quit"; \
			exit 1; \
		elif [ -n "$$SELECTION" ]; then \
			CURRENT_HOST="$$SELECTION"; \
			break; \
		else \
			echo "Invalid selection."; \
			exit 1; \
		fi; \
	done; \
	echo "\033[1;32mSelected host: \033[0;36m'$$CURRENT_HOST'\033[0m\n"; \
	mkdir -p .cache; \
	echo "$$CURRENT_HOST" > .cache/current-host

check-or-install-nix:
	@if command -v nix >/dev/null 2>&1; then \
		echo "\033[1;32mFound a nix binary: \033[0;36m'$$(which nix)'\033[0m"; \
	else \
		echo "NIX binary is not found. Installing.."; \
		curl -L -o .cache/install.sh https://nixos.org/nix/install; \
		$(INSTALL_COMMAND); \
	fi

update-dependencies: 
	nix flake update wallpapers nvim

setup:
ifeq ($(UNAME), Darwin)
	@CURRENT_HOST=$(shell cat .cache/current-host); \
	nix build \
		--extra-experimental-features nix-command \
		--extra-experimental-features flakes \
		".#darwinConfigurations.$$CURRENT_HOST.system"; \

	./result/sw/bin/darwin-rebuild switch --flake ".#$$CURRENT_HOST"
else
	@CURRENT_HOST=$(shell cat .cache/current-host); \
	sudo NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 nixos-rebuild switch --flake ".#$$CURRENT_HOST";
endif

switch:
	$(MAKE) update-dependencies
ifeq ($(UNAME), Darwin)
	nix build ".#darwinConfigurations.${NIX_HOST}.system"
	./result/sw/bin/darwin-rebuild switch --flake ".#${NIX_HOST}"
else
	sudo NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 nixos-rebuild switch --flake ".#${NIX_HOST}"
endif

test:
	$(MAKE) update-dependencies
ifeq ($(UNAME), Darwin)
	nix build ".#darwinConfigurations.${NIX_HOST}.system" --show-trace
	./result/sw/bin/darwin-rebuild build --flake ".#${NIX_HOST}"
else
	sudo NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 nixos-rebuild test --flake ".#$(NIX_HOST)"
endif



