#!/usr/bin/env bash

sh_install() {
  sh -c "$@"
}

sh_list() {
  echo "sh does not record package info" 1>&2
}

bash_install() {
  bash -c "$@"
}

bash_list() {
  echo "bash does not record package info" 1>&2
}

pip_sys_install() {
  pip install "$@"
}

pip_sys__list() {
  pip list
}

pip_user_install() {
  pip install --user $@
}

pip_user_list() {
  pip list --user
}

brew_formula_install() {
  brew install "$@"
}

brew_formula_list() {
  brew list
}

brew_cask_install() {
  brew cask install "$@"
}

brew_cask_list() {
  brew cask list
}

npm_install() {
  npm install -g "$@"
}

npm_list() {
  echo "npm doesn't currently adhear to formatting standards" 1>&2
  npm list -g --depth 0
}

go_install() {
  go get "$@"
}

go_list() {
  go list
}

apt_install(){
  apt-get install "$@"
}

apt_list() {
  apt list --installed
}

pacman_get() {
  pacman -S "$@"
}

pacman_list() {
  pacman -Qqe
}

pacaur_get() {
  pacaur -S "$@"
}

pacaur_list() {
  pacaur -Qqe
}

apple_store_install() {
  echo "apple store install not supported serach for app at https://www.apple.com/uk/search/$@" 1>&2
}

apple_store_list() {
  echo "apple store list not supported" 1>&2
}
