# dotfiles


```console
apt install -y neovim tmux stow
git clone https://www.github.com/raviles/dotfiles
pushd dotfiles
stow -t ~ home
fc-cache -f -v
nvim +PlugInstall
popd
```


# Notes
Update terminal app to use login shell

Download new fonts from https://www.nerdfonts.com/font-downloads
Store in .local/share/fonts/*.ttf and run: fc-cache -f -v

