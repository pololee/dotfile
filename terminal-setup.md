1. Download *iTerm2*  [https://www.iterm2.com/](https://www.iterm2.com/)
2. Install *homebrew*  [https://brew.sh/](https://brew.sh/)
3. Install *zsh*
   ```
   brew install zsh
   ```
4. Install *curl*
   ```
   brew install curl
   ```
5. Install *oh-my-zsh* [https://github.com/robbyrussell/oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh)
   ```
   sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
   ```
   **It should set shell to zsh. If not, use the following command.**
   ```
   chsh -s $(which zsh)
   ```
   It if doesn't work, follow this blog [https://rick.cogley.info/post/use-homebrew-zsh-instead-of-the-osx-default/](https://rick.cogley.info/post/use-homebrew-zsh-instead-of-the-osx-default/)
6. Install *nerd-fonts* [https://github.com/ryanoasis/nerd-fonts#option-4-homebrew-fonts](https://github.com/ryanoasis/nerd-fonts#option-4-homebrew-fonts)
   ```
   brew tap caskroom/fonts
   brew cask install font-hack-nerd-font
   ```
7. Install *powerlevel9k* [https://github.com/bhilburn/powerlevel9k/wiki/Install-Instructions#option-2-install-for-oh-my-zsh](https://github.com/bhilburn/powerlevel9k/wiki/Install-Instructions#option-2-install-for-oh-my-zsh)
   ```
   git clone https://github.com/bhilburn/powerlevel9k.git ~/.oh-my-zsh/custom/themes/powerlevel9k
   ```
8. Link iTerm2 preference profile [https://github.com/pololee/dotfile/blob/master/iterm2_profile/com.googlecode.iterm2.plist](https://github.com/pololee/dotfile/blob/master/iterm2_profile/com.googlecode.iterm2.plist)
9. Update *`.zshr`* based on this [https://github.com/pololee/dotfile/blob/master/zshrc](https://github.com/pololee/dotfile/blob/master/zshrc)

The final output should look like this

