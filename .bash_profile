export PS1="\T \w\$ "

alias gitadd='git add -A .; git status'
alias gitpy='git add *.py; git status'
alias gdd='git diff --cached --color | less -s -M -R +Gg'
alias gds='git diff --stat'
alias batt='pmset -g batt'
alias rls='ls -ltr | tail -30'

export GNUTERM=x11
export GOPATH=/Users/tylerneylon/Dropbox/Documents/code/go
export PATH=/usr/local/bin:/opt/local/bin:/opt/local/sbin:$PATH:$GOPATH/bin
export PATH=/Users/tylerneylon/bin:$PATH:/usr/local/go/bin:.
export EDITOR=vim

settitle() { echo -n -e "\033]0;$@\007"; }

################################################################################
## Tools for working with my gtd setup.
################################################################################

# I can type "cdp ref" to jump to the reference directory.
# This depends on $CDPATH existing as a directory, and containing useful
# symlinks (with short, easy-to-remember names) to other directories.

export CDPATH=/Users/tylerneylon/stuff/symlinks
alias cdp='cd -P'

addlink() {
  if [ ! -z "$1" ]; then
    echo -n "$@ " >> links.txt
  fi
  pbpaste >> links.txt
  # Make sure the file ends in a newline.
  sed -i '' -e '$a\' links.txt
  tail -10 links.txt
}

addpic() {
  if [ -z "$1" ]; then
    echo Usage: addpic '<new_pic_name_no_file_ext>'
    return
  fi
  local orig_path="$(ls -1tr /Users/tylerneylon/Desktop/Screen*.png | tail -1)"
  local ext=${orig_path##*.}
  local new_name=${1}.${ext}
  mv "$orig_path" "$new_name"
  open $new_name
}


if [ -f `brew --prefix`/etc/bash_completion ]; then
  . `brew --prefix`/etc/bash_completion
fi

gfiles() {
  git diff-tree --no-commit-id --name-only -r ${1:-HEAD}
}

pprev() {
  open $(gbcompile --template=/Users/tylerneylon/stuff/tmp/template.html $1)
}

gbprev () {
  open $(gbcompile $1)
}

gbpublish() {
  gbcompile --production
  ./publish.sh
}

set -o vi

rm_voice_notes () { find /Volumes/VN_702PC/RECORDER -name '*.MP3' | xargs rm; }

# I might be able to replace the rm in this function with an exclusion
# rule (or more specific inclusion rule) in using fh.
do_voice_notes () {
  cd /Volumes/VN_702PC/RECORDER || return
  fh = .
  cd "/Users/tylerneylon/Dropbox/Documents/voice notes/voice"
  local dirname=$(7date -d)
  mkdir $dirname
  cd $dirname
  fh cp
  find . -name '*.DAT' | xargs rm
  rm_voice_notes
  diskutil unmount force /Volumes/VN_702PC 
  open FOLDER_A
}

# Usage: $1 = input $2 = output
encrypt() {
  if [ -z "$1" ]; then
    echo Usage: encrypt '<infile>' '[outfile]'
    return
  fi
  if [ -z "$2" ]; then
    out="$1".des3
  else
    out="$2"
  fi
  if [ "$1" == "$out" ]; then
    echo Badness: give me two different filenames please.
    return
  fi

  openssl des3 -salt -in "$1" -out "$out"
}

# Usage: $1 = input $2 = output
decrypt() {
  if [ -z "$1" ]; then
    echo Usage: decrypt '<infile>' '[outfile]'
    return
  fi
  if [ -z "$2" ]; then
    out="${1%.*}"
  else
    out="$2"
  fi
  if [ "$1" == "$out" ]; then
    echo Badness: give me two different filenames please.
    return
  fi
  if [ -e "$out" ]; then
    echo Badness: output file already exists.
    return
  fi

  openssl des3 -d -salt -in "$1" -out "$out"
}

# I use this to check my internet connetion.
pingoo() {
  ping www.google.com
}

alias ls='ls -G'

storestuff() {
  dst="/Users/tylerneylon/stuff/archive_from_desktop/"
  cd ~/Desktop
  for f in *; do
    if [ "$f" != "subdesktop" ]; then
      mv -i "$f" "$dst"
    fi
  done
  cd -
}

gophotos() {
  # FUTURE:
  #  [ ] Update the timestamps files.
  #  [ ] Show some kind of progress indicator.
  dst_base="/Volumes/Laplace/photos/all_photos"
  #dst_base="/Users/tylerneylon/Desktop/photos_todo"
  cd "/Volumes/NO NAME/DCIM"
  for d in 1*CANON; do
    pushd "$d" > /dev/null
    # Only process a directory if it's nonempty.
    if [ "$(ls -A | head -1)" ]; then
      for f in *; do
        file_path="$(pwd)/$f"
        full_7date=$(7date --7month "$file_path")
        day=$(echo $full_7date | cut -f1 -d.)
        year=$(echo $full_7date | cut -f2 -d.)
        dst_dir="$dst_base/$year/$day"
        mkdir -p "$dst_dir"
        cp -p "$file_path" "$dst_dir/"
      done
    fi
    popd > /dev/null
  done
}

rocktest() {
  if [ -z "$1" ]; then
    echo "Usage: rocktest <module_name>"
    return 0
  fi

  sudo luarocks remove "$1"
  sudo luarocks make
}

timey() {
  # Inspired by
  # https://gist.github.com/commanda/775ebcbe630919b554128b31c3dfb9dd
  if [ "$#" -ne 1 ]; then
    echo "usage: timey <number of minutes>"
    return
  fi
  url=https://media.giphy.com/media/yWh7b6fWA5rJm/giphy.gif
  seconds=$(( $1 * 60 ))
  ((sleep $seconds; open -a "Google Chrome.app" $url) &)
  if [ $1 -eq 1 ]; then
    echo Timey set for $1 minute.
  else
    echo Timey set for $1 minutes.
  fi
}

ssfile() {
  f="$(ls -1tr $HOME/Desktop/Screen*.png | tail -1)"
  g=$(echo $f | tr ' ' _)
  mv "$f" "$g"
  echo $g
}


pytags() {
  find . | egrep '\.(py)$' | xargs ctags
}

colortable() {
  tput setaf 0
  for i in $(seq 0 $(tput colors)); do
    tput setab $i
    printf %4d $i
  done
  echo
  tput sgr0
}
