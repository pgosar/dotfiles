# My Dotfiles


## Table of Contents
- [My Dotfiles](#my-dotfiles)
  - [Table of Contents](#table-of-contents)
    - [Installation](#installation)
    - [Dependencies](#dependencies)
    - [Contributing](#contributing)


<hr />

My environment that is currently using an [unmodified starship prompt](https://github.com/starship/starship), [kitty terminal](https://sw.kovidgoyal.net/kitty/), and [tmux](https://github.com/tmux/tmux)

![image](https://user-images.githubusercontent.com/55164602/182411940-805e9c36-c5c1-4688-afe7-06e04ee76495.png)

<hr />

### Installation

If you want to install my files you must first clone the respository with

``` bash

git clone https://github.com/pgosar/dotfiles.git

```

You can then run the install script. Make it executable and run with

```bash

chmod +x ./install.sh ; ./install.sh

```

If you don't want all my files, you can easily remove the lines that remove and then link the files that you do not want to replace. Each file is installed on a per-file basis, making it easy for you to pick and choose what you want. Keep in mind that to get my aliases and Powerlevel 10k config, you have to also download the files located [here](https://github.com/pgosar/dotfiles/tree/main/dotfiles/other)

<hr />

### Dependencies

zsh requires [powerline](powerline/powerline) with the [Meslo nerd font](https://github.com/ryanoasis/nerd-fonts) and [oh my zsh](https://github.com/ohmyzsh/ohmyzsh)

fish requires [tide](https://github.com/ilanCosman/tide)

tmux requires [tpm](https://github.com/tmux-plugins/tpm)

You can refer to the repositories linked above for download instructions, and be sure to give them your support!

<hr />


### Contributing
I welcome contributions if you know of any useful features that I may be missing out on. Feel free to make issues if you find any bugs, have troubles installing or using my files, or have any other concerns.
