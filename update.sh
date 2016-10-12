#!/bin/bash -e
#
# Updates Vim plugins.
#
# All credit for the original file goes to Ian Langworth <statico>
# from https://github.com/statico/dotfiles/blob/master/.vim/update.sh
#
# Update everything (long):
#
#   ./update.sh
#
# Update just the things from Git:
#
#   ./update.sh repos
#
# Update just one plugin from the list of Git repos:
#
#   ./update.sh repos powerline
#

cd ~/

vimdir=$PWD/.vim
bundledir=$vimdir/bundle
tmp=/tmp/$LOGNAME-vim-update
me=.vim/update.sh

# I have an old server with outdated CA certs.
if [ -n "$INSECURE" ]; then
  curl='curl --insecure'
  export GIT_SSL_NO_VERIFY=true
else
  curl='curl'
fi

# URLS --------------------------------------------------------------------

# This is a list of all plugins which are available via Git repos. git:// URLs
# don't work.
repos=(

  https://github.com/tpope/vim-pathogen.git
  https://github.com/tpope/vim-abolish.git
  https://github.com/tpope/vim-surround.git
  https://github.com/tpope/vim-sensible.git
  https://github.com/tpope/vim-fugitive.git
  https://github.com/vim-airline/vim-airline
  https://github.com/scrooloose/nerdcommenter.git
  https://github.com/scrooloose/nerdtree.git
  https://github.com/ctrlpvim/ctrlp.vim.git
  https://github.com/airblade/vim-gitgutter.git
  https://github.com/scrooloose/syntastic.git
  https://github.com/docunext/closetag.vim.git
  https://github.com/mtth/scratch.vim.git

  https://github.com/kchmck/vim-coffee-script.git
  https://github.com/elzr/vim-json.git
  https://github.com/ap/vim-css-color.git
  
  )

# Here's a list of everything else to download in the format
# <destination>;<url>[;<filename>]
other=(

  'vim-l9/autoload;https://bitbucket.org/ns9tks/vim-l9/raw/3bb534a720fa762aa01d2df2d5d41bd3c4122169/autoload/l9.vim'
  'vim-l9/autoload/l9;https://bitbucket.org/ns9tks/vim-l9/raw/3bb534a720fa762aa01d2df2d5d41bd3c4122169/autoload/l9/async.py'
  'vim-l9/autoload/l9;https://bitbucket.org/ns9tks/vim-l9/raw/3bb534a720fa762aa01d2df2d5d41bd3c4122169/autoload/l9/async.vim'
  'vim-l9/autoload/l9;https://bitbucket.org/ns9tks/vim-l9/raw/3bb534a720fa762aa01d2df2d5d41bd3c4122169/autoload/l9/quickfix.vim'
  'vim-l9/autoload/l9;https://bitbucket.org/ns9tks/vim-l9/raw/3bb534a720fa762aa01d2df2d5d41bd3c4122169/autoload/l9/tempbuffer.vim'
  'vim-l9/autoload/l9;https://bitbucket.org/ns9tks/vim-l9/raw/3bb534a720fa762aa01d2df2d5d41bd3c4122169/autoload/l9/tempvariables.vim'
  'vim-l9/doc;https://bitbucket.org/ns9tks/vim-l9/raw/3bb534a720fa762aa01d2df2d5d41bd3c4122169/doc/l9.jax'
  'vim-l9/doc;https://bitbucket.org/ns9tks/vim-l9/raw/3bb534a720fa762aa01d2df2d5d41bd3c4122169/doc/l9.txt'
  'vim-l9/plugin;https://bitbucket.org/ns9tks/vim-l9/raw/3bb534a720fa762aa01d2df2d5d41bd3c4122169/plugin/l9.vim'
  'vim-autocomplpop/autoload;https://bitbucket.org/ns9tks/vim-autocomplpop/raw/13fe3d8064647e2cdf07e12840108c3f917f5636/autoload/acp.vim'
  'vim-autocomplpop/plugin;https://bitbucket.org/ns9tks/vim-autocomplpop/raw/13fe3d8064647e2cdf07e12840108c3f917f5636/plugin/acp.vim'
  'vim-autocomplpop/doc;https://bitbucket.org/ns9tks/vim-autocomplpop/raw/13fe3d8064647e2cdf07e12840108c3f917f5636/doc/acp.txt'
  'vim-autocomplpop/doc;https://bitbucket.org/ns9tks/vim-autocomplpop/raw/13fe3d8064647e2cdf07e12840108c3f917f5636/doc/acp.jax'
  'zenburn/colors;https://raw.githubusercontent.com/jnurmine/Zenburn/master/colors/zenburn.vim'
  'wombat/colors;http://files.werx.dk/wombat.vim'
  'coffee/colors;https://raw.githubusercontent.com/duythinht/vim-coffee/master/colors/coffee.vim'
  'molokai/colors;https://raw.githubusercontent.com/tomasr/molokai/master/colors/molokai.vim'
 # 'glsl/syntax;http://www.vim.org/scripts/download_script.php?src_id=3194;glsl.vim'

  )

case "$1" in

  # GIT -----------------------------------------------------------------
  repos|repo)
    mkdir -p $bundledir
    for url in ${repos[@]}; do
      if [ -n "$2" ]; then
        if ! (echo "$url" | grep "$2" &>/dev/null) ; then
          continue
        fi
      fi
      dest="$bundledir/$(basename $url | sed -e 's/\.git$//')"
      rm -rf $dest
      echo "Cloning $url into $dest"
      git clone -q $url $dest
      rm -rf $dest/.git
    done
    ;;

  # TARBALLS AND SINGLE FILES -------------------------------------------
  other)
    set -x
    mkdir -p $bundledir
    rm -rf $tmp
    mkdir $tmp
    pushd $tmp

    for pair in ${other[@]}; do
      parts=($(echo $pair | tr ';' '\n'))
      name=${parts[0]}
      url=${parts[1]}
      filename=${parts[2]}
      dest=$bundledir/$name

      rm -rf $dest

      if echo $url | egrep '.zip$'; then
        # Zip archives from VCS tend to have an annoying outer wrapper
        # directory, so unpacking them into their own directory first makes it
        # easy to remove the wrapper.
        f=download.zip
        $curl -L $url >$f
        unzip $f -d $name
        mkdir -p $dest
        mv $name/*/* $dest
        rm -rf $name $f

      else
        # Assume single files. Create the destination directory and download
        # the file there.
        mkdir -p $dest
        pushd $dest
        if [ -n "$filename" ]; then
          $curl -L $url >$filename
        else
          $curl -OL $url
        fi
        popd

      fi

    done

    popd
    rm -rf $tmp
    ;;

  # HELP ----------------------------------------------------------------

  all)
    $me repos
    $me other
    echo
    echo "Update OK"
    ;;

  *)
    set +x
    echo
    echo "Usage: $0 <section> [<filter>]"
    echo "...where section is one of:"
    grep -E '\w\)$' $me | sed -e 's/)//'
    echo
    echo "<filter> can be used with the 'repos' section."
    exit 1

esac
