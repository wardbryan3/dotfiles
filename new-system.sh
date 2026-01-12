#This Script is to be used on arch-based systems only

#First update the system
sudo pacman -Syu

echo "Installing essential packages"
#Installls
sudo pacman -S lazygit github-cli neovim btop fastfetch eza vivaldi kitty fish

echo "Setting git config name and e-mail"
#git
git config --global user.name "Bryan Ward"
git config --global user.email "wardbryan3@gmail.com"

echo Installing LazyVim
#LazyVim
echo "Backing up current nvim configs"
mv ~/.config/nvim{,.bak}
echo "Installing LazyVim"
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git

#github login
gh auth login

#Execute configuration imports
exec link-configs.sh
