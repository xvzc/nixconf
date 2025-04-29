SHELL := /bin/sh

SELECTIONS := \
  macair-personal-phys-01 \
  desktop-personal-phys-01 \
  quit

UNAME := $(shell uname)

ifeq ($(UNAME), Darwin)
INSTALL_COMMAND := echo 'this is a macos install command'
else
INSTALL_COMMAND := echo 'this is a linux install command'
endif

clean: 
	@rm -rf .cache
	@echo "Cleaned cache\n"

init: .cache/ran-setup

.cache/current-machine:
	$(MAKE) select-current-machine

.cache/has-nix: | .cache/current-machine
	$(MAKE) install-nix
	@touch .cache/has-nix

.cache/ran-setup: | .cache/has-nix
	$(MAKE) setup;
	@touch .cache/ran-setup

select-current-machine:
	@echo "Select a machine:"
	@select SELECTION in ${SELECTIONS}; do \
		if [ "$$SELECTION" = "quit" ]; then \
			echo "quit"; \
			exit 0; \
		elif [ -n "$$SELECTION" ]; then \
			CURRENT_MACHINE="$$SELECTION"; \
			break; \
		else \
			echo "Invalid selection."; \
			exit 1; \
		fi; \
	done; \
	echo "\033[1;32mSelected machine: \033[0;36m'$$CURRENT_MACHINE'\033[0m\n"; \
	mkdir -p .cache; \
	echo "$$CURRENT_MACHINE" > .cache/current-machine

install-nix:
	@if command -v nix >/dev/null 2>&1; then \
		echo "\033[1;32mFound nix binary: \033[0;36m'$$(which nix)'\033[0m"; \
	else \
		echo "NIX binary is not found. Installing.."; \
		curl -L -o .cache/install.sh https://nixos.org/nix/install; \
		$(INSTALL_COMMAND); \
	fi

setup:
	@echo "Fetching "
	test -d ~/.config || mkdir -p ~/.config
	test -d ~/.config/nvim || git clone https://github.com/xvzc/nvim ~/.config/nvim
ifeq ($(UNAME), Darwin)
	nix build \
		--extra-experimental-features nix-command \
		--extra-experimental-features flakes \
		".#darwinConfigurations.${MACHINE}.system"

	./result/sw/bin/darwin-rebuild switch --flake ".#${MACHINE}"
else
	sudo NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 nixos-rebuild switch --flake ".#${MACHINE}"
endif

switch:
ifeq ($(UNAME), Darwin)
	nix build ".#darwinConfigurations.${NIXNAME}.system"
	./result/sw/bin/darwin-rebuild switch --flake ".#${NIXNAME}"
else
	sudo NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 nixos-rebuild switch --flake ".#${NIXNAME}"
endif

test:
ifeq ($(UNAME), Darwin)
	nix build ".#darwinConfigurations.${NIXNAME}.system" --show-trace
	./result/sw/bin/darwin-rebuild build --flake ".#${NIXNAME}"
else
	sudo NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 nixos-rebuild test --flake ".#$(NIXNAME)"
endif



