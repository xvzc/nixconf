# The name of the nixosConfiguration in the flake
NIXNAME ?= macbook-air-m2

# We need to do some OS switching below.
UNAME := $(shell uname)

switch:
ifeq ($(UNAME), Darwin)
	nix build --extra-experimental-features nix-command --extra-experimental-features flakes ".#darwinConfigurations.${NIXNAME}.system"
	./result/sw/bin/darwin-rebuild switch --flake ".#${NIXNAME}"
else
	sudo NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 nixos-rebuild switch --flake ".#${NIXNAME}"
endif


test:
ifeq ($(UNAME), Darwin)
	nix build --extra-experimental-features nix-command --extra-experimental-features flakes ".#darwinConfigurations.${NIXNAME}.system" --show-trace
	./result/sw/bin/darwin-rebuild build --flake ".#${NIXNAME}"
else
	sudo NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 nixos-rebuild test --flake ".#$(NIXNAME)"
endif

