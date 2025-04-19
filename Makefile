UNAME := $(shell uname)

init:
	[ -f ~/.zprofile ] || touch ~/.zprofile \
		&& grep -q '^export NIXNAME=' ~/.zprofile \
		|| echo "export NIXNAME='${NIXNAME}'" >> ~/.zprofile
	export NIXNAME='${NIXNAME}'

ifeq ($(UNAME), Darwin)
	command -v nix \
		|| command -v /nix/var/nix/profiles/default/bin/nix \
		|| curl -L https://nixos.org/nix/install | sh

	command -v nix || . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

	nix build \
		--extra-experimental-features nix-command \
		--extra-experimental-features flakes \
		".#darwinConfigurations.${NIXNAME}.system"

	./result/sw/bin/darwin-rebuild switch --flake ".#${NIXNAME}"
else
	sudo NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 nixos-rebuild switch --flake ".#${NIXNAME}"
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



