# Ubuntu-only stuff. Abort if not Ubuntu.
is_ubuntu || return 1

apt_keys=()
apt_source_files=()
apt_source_texts=()
apt_packages=()
deb_installed=()
deb_sources=()

installers_path="$DOTFILES/caches/installers"

# Ubuntu distro release name, eg. "xenial"
release_name=$(lsb_release -c | awk '{print $2}')

function add_ppa() {
  apt_source_texts+=($1)
  IFS=':/' eval 'local parts=($1)'
  apt_source_files+=("${parts[1]}-ubuntu-${parts[2]}-$release_name")
}

#############################
# WHAT DO WE NEED TO INSTALL?
#############################

# Misc.
apt_packages+=(
#   awscli
  build-essential
#   cmatrix
#   cowsay
  curl
#   docker.io
#   docker-compose
#   git-core
#   groff
#   hollywood
#   htop
#   id3tool
#   imagemagick
#   jq
#   mercurial
#   nmap
#   postgresql
  python3-pip
#   silversearcher-ag
#   sl
#   telnet
#   thefuck
  tree

# new for bruceoberg
  micro
  gh
)

# https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-ansible-on-ubuntu-16-04
add_ppa ppa:ansible/ansible
apt_packages+=(ansible)

# if is_ubuntu_desktop; then
#   # https://www.techrepublic.com/article/how-to-connect-a-linux-machine-to-google-cloud-print/
#   # sudo /usr/share/cloudprint-cups/setupcloudprint.py
#   add_ppa ppa:simon-cadman/niftyrepo
#   apt_packages+=(cupscloudprint)

#   # https://github.com/tagplus5/vscode-ppa
#   apt_keys+=(https://tagplus5.github.io/vscode-ppa/ubuntu/gpg.key)
#   apt_source_files+=(vscode.list)
#   apt_source_texts+=("deb https://tagplus5.github.io/vscode-ppa/ubuntu ./")
#   apt_packages+=(code code-insiders)

#   # https://www.ubuntuupdates.org/ppa/google_chrome
#   apt_keys+=(https://dl-ssl.google.com/linux/linux_signing_key.pub)
#   apt_source_files+=(google-chrome)
#   apt_source_texts+=("deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main")
#   apt_packages+=(google-chrome-stable)

  # Misc
  # apt_packages+=(adb fastboot)
#   apt_packages+=(
#     chromium-browser
#     fonts-mplus
#     gnome-tweak-tool
#     k4dirstat
#     rofi
#     network-manager-openconnect
#     network-manager-openconnect-gnome
#     openssh-server
#     shutter
#     unity-tweak-tool
#     vlc
#     xclip
#     zenmap
#   )

#   # Manage online accounts via "gnome-control-center" in launcher
#   apt_packages+=(gnome-control-center gnome-online-accounts)

#   # https://github.com/mitchellh/vagrant/issues/7411
#   deb_installed+=(/usr/bin/vagrant)
#   deb_sources+=(https://releases.hashicorp.com/vagrant/1.9.2/vagrant_1.9.2_x86_64.deb)
#   # https://github.com/vagrant-libvirt/vagrant-libvirt/issues/575
#   # apt_packages+=(vagrant)
#   # function postinstall_vagrant() {
#   #   sudo sed -i'' "s/Specification.all = nil/Specification.reset/" /usr/lib/ruby/vendor_ruby/vagrant/bundler.rb
#   # }

#   # https://www.dropbox.com/install-linux
#   apt_packages+=(python-gtk2 python-gpgme)
#   deb_installed+=(/usr/bin/dropbox)
#   deb_sources+=("https://www.dropbox.com/download?dl=packages/ubuntu/dropbox_2015.10.28_amd64.deb")

#   # http://askubuntu.com/a/852727
#   apt_packages+=(cabextract)
#   deb_installed+=(/usr/share/fonts/truetype/msttcorefonts)
#   deb_sources+=(deb_source_msttcorefonts)
#   function deb_source_msttcorefonts() {
#     echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | sudo debconf-set-selections
#     echo http://ftp.debian.org/debian/pool/contrib/m/msttcorefonts/ttf-mscorefonts-installer_3.6_all.deb
#   }

#   # https://slack.com/downloads/instructions/linux
#   deb_installed+=(/usr/bin/slack)
#   deb_sources+=(https://downloads.slack-edge.com/linux_releases/slack-desktop-2.5.2-amd64.deb)

#   # https://discordapp.com/download
#   deb_installed+=(/usr/bin/discord)
#   deb_sources+=("https://discordapp.com/api/download?platform=linux&format=deb")

#   # http://askubuntu.com/questions/854480/how-to-install-the-steam-client/854481#854481
#   apt_packages+=(python-apt)
#   deb_installed+=(/usr/bin/steam)
#   deb_sources+=(deb_source_steam)
#   function deb_source_steam() {
#     local steam_root steam_file
#     steam_root=http://repo.steampowered.com/steam/pool/steam/s/steam/
#     steam_file="$(wget -q -O- "$steam_root?C=M;O=D" | sed -En '/steam-launcher/{s/.*href="([^"]+)".*/\1/;p;q;}')"
#     echo "$steam_root$steam_file"
#   }
  # https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=772598
  # apt_packages+=(steam)
  # function preinstall_steam() {
  #   echo steam steam/question select I AGREE | sudo debconf-set-selections
  #   echo steam steam/license note | sudo debconf-set-selections
  # }
# fi

function other_stuff() {
  # Install Git Extras
  if [[ ! "$(type -P git-extras)" ]]; then
    e_header "Installing Git Extras"
    (
      cd $DOTFILES/vendor/git-extras &&
      sudo make install
    )
  fi
  # Install Rename
  if [[ ! "$(type -P rename)" ]]; then
    e_header "Installing Rename"
    (
      cd $DOTFILES/vendor/rename &&
      cp rename $DOTFILES/bin
    )
  fi
  # Install misc bins from zip file.
#   install_from_zip ngrok 'https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip'
#   install_from_zip terraform 'https://releases.hashicorp.com/terraform/0.9.2/terraform_0.9.2_linux_amd64.zip'
}

####################
# ACTUALLY DO THINGS
####################

# Add APT keys.
keys_cache=$DOTFILES/caches/init/apt_keys
IFS=$'\n' GLOBIGNORE='*' command eval 'setdiff_cur=($(<$keys_cache))'
setdiff_new=("${apt_keys[@]}"); setdiff; apt_keys=("${setdiff_out[@]}")
unset setdiff_new setdiff_cur setdiff_out

if (( ${#apt_keys[@]} > 0 )); then
  e_header "Adding APT keys (${#apt_keys[@]})"
  for key in "${apt_keys[@]}"; do
    e_arrow "$key"
    if [[ "$key" =~ -- ]]; then
      sudo apt-key adv $key
    else
      wget -qO- $key | sudo apt-key add -
    fi && \
    echo "$key" >> $keys_cache
  done
fi

# Add APT sources.
function __temp() { [[ ! -e /etc/apt/sources.list.d/$1.list ]]; }
source_i=($(array_filter_i apt_source_files __temp))

if (( ${#source_i[@]} > 0 )); then
  e_header "Adding APT sources (${#source_i[@]})"
  for i in "${source_i[@]}"; do
    source_file=${apt_source_files[i]}
    source_text=${apt_source_texts[i]}
    if [[ "$source_text" =~ ppa: ]]; then
      e_arrow "$source_text"
      sudo add-apt-repository -y $source_text
    else
      e_arrow "$source_file"
      sudo sh -c "echo '$source_text' > /etc/apt/sources.list.d/$source_file.list"
    fi
  done
fi

# Update APT.
e_header "Updating APT"
sudo apt-get -qq update

# Only do a dist-upgrade on initial install, otherwise do an upgrade.
e_header "Upgrading APT"
if is_dotfiles_bin; then
  sudo apt-get -qy upgrade
else
  sudo apt-get -qy dist-upgrade
fi

# Install APT packages.
installed_apt_packages="$(dpkg --get-selections | grep -v deinstall | awk 'BEGIN{FS="[\t:]"}{print $1}' | uniq)"
apt_packages=($(setdiff "${apt_packages[*]}" "$installed_apt_packages"))

if (( ${#apt_packages[@]} > 0 )); then
  e_header "Installing APT packages (${#apt_packages[@]})"
  for package in "${apt_packages[@]}"; do
    e_arrow "$package"
    [[ "$(type -t preinstall_$package)" == function ]] && preinstall_$package
    sudo apt-get -qq install "$package" && \
    [[ "$(type -t postinstall_$package)" == function ]] && postinstall_$package
  done
fi

# Install debs via dpkg
function __temp() { [[ ! -e "$1" ]]; }
deb_installed_i=($(array_filter_i deb_installed __temp))

if (( ${#deb_installed_i[@]} > 0 )); then
  mkdir -p "$installers_path"
  e_header "Installing debs (${#deb_installed_i[@]})"
  for i in "${deb_installed_i[@]}"; do
    e_arrow "${deb_installed[i]}"
    deb="${deb_sources[i]}"
    [[ "$(type -t "$deb")" == function ]] && deb="$($deb)"
    installer_file="$installers_path/$(echo "$deb" | sed 's#.*/##')"
    wget -O "$installer_file" "$deb"
    sudo dpkg -i "$installer_file"
  done
fi

# install bins from zip file
function install_from_zip() {
  local name=$1 url=$2 bins b zip tmp
  shift 2; bins=("$@"); [[ "${#bins[@]}" == 0 ]] && bins=($name)
  if [[ ! "$(which $name)" ]]; then
    mkdir -p "$installers_path"
    e_header "Installing $name"
    zip="$installers_path/$(echo "$url" | sed 's#.*/##')"
    wget -O "$zip" "$url"
    tmp=$(mktemp -d)
    unzip "$zip" -d "$tmp"
    for b in "${bins[@]}"; do
      sudo cp "$tmp/$b" "/usr/local/bin/$(basename $b)"
    done
    rm -rf $tmp
  fi
}

# Run anything else that may need to be run.
type -t other_stuff >/dev/null && other_stuff
