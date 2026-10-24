export PATH=$PATH:$HOME/.local/bin

if [ -z "$__NIX_PORTABLE_ACTIVATED" ]; then
        export __NIX_PORTABLE_ACTIVATED=1
        NP_RUNTIME=bwrap nix-portable nix run nixpkgs#bashInteractive --offline
        exit
else
        . $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh
	if [ -z "$NIX_BUILD_TOP" ] && [ -t 0 ] && command -v nu >/dev/null 2>&1; then
		exec nu
	fi
fi

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Set something for the cmd line
PS1='[\u@\h \W]\$ '
