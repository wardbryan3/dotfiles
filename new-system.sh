#Installls
sudo pacman -S lazygit github-cli neovim btop fastfetch eza vivaldi kitty fish

#git
git config --global user.name "Bryan Ward"
git config --global user.email "wardbryan3@gmail.com"

#LazyVim
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git

#github login
gh auth login
