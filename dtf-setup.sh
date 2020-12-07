#!/bin/sh

BARE_GIT_FOLDER="$HOME/.dotfiles-git"

ALIAS_FILE="$HOME/.shell_aliases"
ALIAS="dtf"
ALIAS_EXPR="/usr/bin/git --git-dir=$BARE_GIT_FOLDER/ --work-tree=$HOME"

WOULD_BE_CLOBBERED_BACKUP_DIR="$HOME/.dotfiles-backup"

update_alias_file() 
{
  echo ""                    >> $ALIAS_FILE
  echo "$ALIAS()"            >> $ALIAS_FILE
  echo "{"                   >> $ALIAS_FILE
  echo "  $ALIAS_EXPR \$*"   >> $ALIAS_FILE
  echo "}"                   >> $ALIAS_FILE

  echo ""
  echo "... modified $ALIAS_FILE" 

  echo ""
  echo "In order to use to use new \"$ALIAS\" command, please do (1) AND/OR (2):"
  echo ""
  echo "(1)" 
  echo "run this command in all interactive terminals:"
  echo "source $ALIAS_FILE"
  echo ""
  echo "(2)" 
  echo "if $ALIAS_FILE is sourced by your shell at bootup, exit and reopen all your shells"
}

setup_alias()
{
  if [ -f "$ALIAS_FILE" ]; then
    if ! grep -q "$ALIAS()" "$ALIAS_FILE"; then
      update_alias_file
    fi
  else
    update_alias_file
  fi
}

setup_git()
{
  if [ ! -d "$BARE_GIT_FOLDER" ]; then
    mkdir $BARE_GIT_FOLDER
    git init --bare $BARE_GIT_FOLDER
  fi

  $ALIAS_EXPR config --local status.showUntrackedFiles no
}

clone()
{
  if [ ! -d "$BARE_GIT_FOLDER" ]; then
    git clone --bare https://github.qualcomm.com/dpassmor/dotfiles $BARE_GIT_FOLDER
  fi

  $ALIAS_EXPR checkout

  if [ $? = 0 ]; then
    echo "didn't need to back anything up as nothing would be overriten"
  else
    echo "Backing up pre-existing dot files into $WOULD_BE_CLOBBERED_BACKUP_DIR";
    mkdir -p $WOULD_BE_CLOBBERED_BACKUP_DIR
    $ALIAS_EXPR checkout 2>&1 | egrep "^\s+\S+\$" | awk {'print $1'} | xargs -I{} sh -c "echo \"moving {} to $WOULD_BE_CLOBBERED_BACKUP_DIR/{}\"; mkdir -p \$(dirname $WOULD_BE_CLOBBERED_BACKUP_DIR/{}); mv {} $WOULD_BE_CLOBBERED_BACKUP_DIR/{};" 
    $ALIAS_EXPR checkout
  fi;
  echo "cloned config files!";

  $ALIAS_EXPR config --local status.showUntrackedFiles no
}

#useful for first-time creation of git repo
#setup_git

# for when cloning git repo
clone

setup_alias
