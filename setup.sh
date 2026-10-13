#! /bin/bash
{
  GREEN='\033[1;32m'
  NC='\033[0m'

  echo -e "${GREEN}==> Downloading dotfiles archive...${NC}"
  curl -sL https://github.com/raviles/dotfiles/archive/refs/heads/main.zip -o /tmp/dotfiles.zip
  
  echo -e "${GREEN}==> Extracting to ~/dotfiles...${NC}"
  unzip -qo /tmp/dotfiles.zip -d /tmp/
  rm -rf ~/dotfiles && mv /tmp/dotfiles-main ~/dotfiles
  
  echo -e "${GREEN}==> Installing dependencies...${NC}"
  sudo apt-get update && sudo apt-get install -y neovim tmux stow git unzip fontconfig
  
  echo -e "${GREEN}==> Stowing configurations...${NC}"
  cd ~/dotfiles && stow -t ~ home
  
  echo -e "${GREEN}==> Configuring ~/.bashrc...${NC}"
  touch ~/.bashrc # Ensures the file exists so grep doesn't throw an error
  if ! grep -q "\.bash_local" ~/.bashrc; then
      echo -e "\n# Source local settings\nif [ -f ~/.bash_local ]; then\n    source ~/.bash_local\nfi" >> ~/.bashrc
  fi
  
  echo -e "${GREEN}==> Updating font cache...${NC}"
  fc-cache -f -v >/dev/null
  
  echo -e "${GREEN}==> Installing Neovim plugins...${NC}"
  nvim +PlugInstall +qa
  
  echo -e "${GREEN}==> Cleaning up...${NC}"
  rm /tmp/dotfiles.zip
  
  echo -e "${GREEN}==> Setup complete!${NC}"
}
