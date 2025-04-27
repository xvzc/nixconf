UNAME := $(shell uname)
SELECTIONS = \
  macair-personal-phys-01 \
  desktop-personal-phys-01 \
  quit

default: select

select:
	@echo "Select a NIXNAME:"
	@select SELECTION in ${SELECTIONS}; do \
		if [ "$$SELECTION" = "quit" ]; then \
			echo "quit"; \
			exit 0; \
		elif [ -n "$$SELECTION" ]; then \
			MACHINE="$$SELECTION"; \
			echo "Got $$SELECTION..."; \
			break; \
		else \
			echo "Invalid selection."; \
			exit 1; \
		fi; \
	done; \
	$(MAKE) init MACHINE="$$MACHINE"
init:
	echo "Got: ${MACHINE}"

ifeq ($(UNAME), Darwin)
	nix build \
		--extra-experimental-features nix-command \
		--extra-experimental-features flakes \
		".#darwinConfigurations.${MACHINE}.system"

	./result/sw/bin/darwin-rebuild switch --flake ".#${MACHINE}"
else
	sudo NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 nixos-rebuild switch --flake ".#${MACHINE}"
endif
	test -d ~/.config || mkdir -p ~/.config
	test -d ~/.config/nvim || git clone https://github.com/xvzc/nvim ~/.config/nvim

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



