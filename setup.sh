{
  # Exit immediately if any command fails
  set -e 

  GREEN='\033[1;32m'
  YELLOW='\033[1;33m'
  RED='\033[1;31m'
  NC='\033[0m'

  DEPS="curl unzip git neovim tmux stow fontconfig"
  BACKUP=~/dotfiles.bak.$$
  STAGED=0

  # Ask a yes/no question; reads from the terminal so it works under `curl | bash`
  confirm() {
      local reply
      read -r -p "$1 [y/N] " reply < /dev/tty
      [[ "$reply" =~ ^[Yy]([Ee][Ss])?$ ]]
  }

  # Undo the staged ~/dotfiles swap and remove temp files if we exit early
  cleanup() {
      if [ "$STAGED" = 1 ]; then
          rm -rf ~/dotfiles
          if [ -e "$BACKUP" ]; then mv "$BACKUP" ~/dotfiles; fi
      fi
      rm -rf /tmp/dotfiles.zip /tmp/dotfiles-main
  }
  trap cleanup EXIT

  echo -e "${GREEN}==> Checking dependencies...${NC}"
  MISSING=""
  for pkg in $DEPS; do
      if ! dpkg-query -W -f='${Status}' "$pkg" 2>/dev/null | grep -q "install ok installed"; then
          MISSING="$MISSING $pkg"
      fi
  done

  if [ -n "$MISSING" ]; then
      echo -e "${YELLOW}Missing packages:${NC}$MISSING"
      if ! confirm "Install them with apt?"; then
          echo -e "${RED}Aborted: dependencies not installed.${NC}"
          exit 1
      fi
      echo -e "${GREEN}==> Installing dependencies...${NC}"
      sudo apt-get update && sudo apt-get install -y $MISSING
  else
      echo "All dependencies already installed."
  fi
  
  echo -e "${GREEN}==> Downloading dotfiles archive...${NC}"
  curl -sL https://github.com/raviles/dotfiles/archive/refs/heads/main.zip -o /tmp/dotfiles.zip
  
  echo -e "${GREEN}==> Extracting to ~/dotfiles...${NC}"
  rm -rf /tmp/dotfiles-main
  unzip -qo /tmp/dotfiles.zip -d /tmp/
  # Stage at the final location so the dry run sees the real link targets;
  # any existing ~/dotfiles is kept as a backup until the stow succeeds
  if [ -e ~/dotfiles ]; then
      echo -e "${YELLOW}~/dotfiles already exists.${NC} It will be moved to $BACKUP and replaced."
      if ! confirm "Proceed?"; then
          echo -e "${RED}Aborted: existing ~/dotfiles left untouched.${NC}"
          exit 1
      fi
      STAGED=1
      mv ~/dotfiles "$BACKUP"
  fi
  STAGED=1
  mv /tmp/dotfiles-main ~/dotfiles
  
  echo -e "${GREEN}==> Simulating stow (dry run)...${NC}"
  cd ~/dotfiles
  if ! stow -n -v -t ~ home; then
      echo -e "${RED}Aborted: stow reported conflicts. Resolve them and re-run.${NC}"
      exit 1
  fi
  if ! confirm "Apply the changes above?"; then
      echo -e "${RED}Aborted: nothing was stowed.${NC}"
      exit 1
  fi

  echo -e "${GREEN}==> Stowing configurations...${NC}"
  stow -t ~ home
  STAGED=0
  rm -rf "$BACKUP"
  
  echo -e "${GREEN}==> Configuring ~/.bashrc...${NC}"
  touch ~/.bashrc
  if ! grep -q "\.bash_local" ~/.bashrc; then
      echo -e "\n# Source local settings\nif [ -f ~/.bash_local ]; then\n    source ~/.bash_local\nfi" >> ~/.bashrc
  fi
  
  echo -e "${GREEN}==> Updating font cache...${NC}"
  fc-cache -f -v >/dev/null
  
  echo -e "${GREEN}==> Installing Neovim plugins...${NC}"
  nvim +PlugInstall +qa
  
  echo -e "${GREEN}==> Setup complete!${NC}"
}
