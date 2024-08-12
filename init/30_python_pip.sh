# Homebrew installs python2 pip as "pip2"
for pip_cmd in pip pip3 FAIL; do [[ "$(which $pip_cmd)" ]] && break; done

# Exit if pip is not installed.
[[ $pip_cmd == FAIL ]] && e_error "Pip needs to be installed." && return 1

# Add pip packages
pip_packages=(
aenum
appdirs
arabic-reshaper
arrow
asttokens
Babel
backcall
certifi
charset-normalizer
colorama
comm
dateutils
debugpy
decorator
defusedxml
docopt
et-xmlfile
executing
facepy
fonttools
fpdf2
future
icecream
idna
ipykernel
ipython
jedi
jupyter_client
jupyter_core
lxml
matplotlib-inline
nest-asyncio
openpyxl
packaging
parso
pickleshare
Pillow
pipreqs
platformdirs
prompt-toolkit
psutil
pure-eval
pyaml
Pygments
PySnooper
python-bidi
python-dateutil
python-docx
pytz
PyYAML
pyzmq
reportlab
requests
six
stack-data
svg.path
tornado
traitlets
types-python-dateutil
typing_extensions
unicategories
urllib3
userpaths
wcwidth
yarg
)

# is_osx || pip_packages+=(powerline-status)

installed_pip_packages="$($pip_cmd list 2>/dev/null | awk '{print $1}')"
pip_packages=($(setdiff "${pip_packages[*]}" "$installed_pip_packages"))

if (( ${#pip_packages[@]} > 0 )); then
  e_header "Installing pip packages (${#pip_packages[@]})"
  for package in "${pip_packages[@]}"; do
    e_arrow "$package"
    $pip_cmd install "$package"
  done
fi
