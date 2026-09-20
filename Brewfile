# Tools the configs in this repo actually depend on — not a dump of `brew list`.
# Install with:  brew bundle --file=~/mycode/dotfiles/Brewfile
#
# Grouped by what breaks if it's missing.

# --- shell: sourced by zsh/conf.d/99-plugins-last.zsh ------------------------
brew "zsh-autosuggestions"
brew "zsh-syntax-highlighting"
brew "zsh-history-substring-search"

# --- prompt and navigation: zsh/conf.d/50-tools.zsh -------------------------
brew "starship"
brew "zoxide"
brew "fzf"

# --- CLI replacements assumed by zsh/conf.d/30-aliases.zsh ------------------
brew "eza"                # ls
brew "bat"                # cat / pager
brew "ripgrep"            # grep
brew "fd"                 # find
brew "tree"
brew "jq"

# --- git: pager and TUI referenced by git/gitconfig + config/lazygit --------
brew "git"
brew "git-delta"
brew "lazygit"

# --- editor: config/nvim (LazyVim) ------------------------------------------
brew "neovim"
brew "luajit"             # LazyVim's jit path
brew "tree-sitter"
brew "shellcheck"         # mason installs these too; having them on PATH is
brew "shfmt"              # faster and works offline

# --- language toolchains: zsh/conf.d/25-toolchains.zsh -----------------------
brew "fnm"                # node (Fast Node Manager)
brew "rv"                 # ruby; `try` is a gem inside rv's Ruby
# bun is NOT here on purpose: it's installed via its own installer at ~/.bun
# (not a Homebrew formula) — see 25-toolchains.zsh.

# --- terminal multiplexing --------------------------------------------------
brew "herdr"              # config/herdr — https://herdr.dev
brew "tmux"

# --- misc -------------------------------------------------------------------
brew "gh"
brew "direnv"
brew "coreutils"
brew "watchman"           # backs core.fsmonitor for large repos

# --- GUI --------------------------------------------------------------------
# Terminal. Its config lives in config/ghostty/config.
cask "ghostty"
# macOS automation. Its config lives in hammerspoon/ — note it reads
# ~/.hammerspoon, which install.sh symlinks.
cask "hammerspoon"
# Launcher and window manager. Config is NOT tracked (see docs/machine-local.md);
# window-management shortcuts are set up by hand, see docs/mac-setup.md.
cask "raycast"

# Apps the Hammerspoon hyper-key bindings launch. Without these,
# hammerspoon/modules/app_hotkeys.lua binds chords to apps that aren't installed,
# and chrome_vertical_tabs.lua has nothing to drive.
cask "google-chrome"      # hyper+o, plus the vertical-tabs module
cask "slack"              # hyper+s
cask "cursor"             # hyper+;
cask "visual-studio-code" # hyper+'

# --- Fonts ------------------------------------------------------------------
# Referenced by config/ghostty/config (font-family = VictorMono Nerd Font).
cask "font-victor-mono-nerd-font"
# Not referenced by any config here, but installed on the machine and handy as a
# second terminal font. Drop it if you never switch.
cask "font-iosevka-nerd-font"
