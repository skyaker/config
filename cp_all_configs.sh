rm brewfile
brew bundle dump --file=~/.dotfiles/config/brewfile
rm -rf sketchybar
cp -r -- ~/.config/sketchybar/. ./sketchybar
cp ~/.zshrc .
cp ~/.hammerspoon/init.lua .