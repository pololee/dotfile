alias ls='ls --color=auto'
if [ "$color_prompt" = yes ]; then
  PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\W\[\033[00m\]\$ '
else
  PS1='${debian_chroot:+($debian_chroot)}\u@\h:\W\$ '
fi
PS1='\[\e[1;92m\][\u@\h: \W]\$\[\e[0m\] '
