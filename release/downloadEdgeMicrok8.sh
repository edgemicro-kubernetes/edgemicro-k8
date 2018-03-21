#! /bin/sh
#
# Download edgemicro-k8

OS="$(uname)"
if [ "x${OS}" = "xDarwin" ] ; then
  arch="$(uname -m)"
  if [ "y${arch}" = "yx86_64" ]; then
  	OSEXT="darwinamd64"
  else
  	OSEXT="darwin386"
  fi
else
  # TODO we should check more/complain if not likely to work, etc...
  arch="$(uname -m)"
  if [ "y${arch}" = "yx86_64" ]; then
  	OSEXT="linuxamd64"
  else
  	OSEXT="linux386"
  fi
fi



if [ "x${EDGEMICRO_VERSION}" = "x" ] ; then
  EDGEMICRO_VERSION=$(curl -L -s https://api.github.com/repos/edgemicro-kubernetes/edgemicro-k8/releases/latest | \
                  grep tag_name | sed "s/ *\"tag_name\": *\"\(.*\)\",*/\1/")
fi

NAME="edgemicro-k8-$EDGEMICRO_VERSION-$OSEXT"

echo $NAME


URL="https://github.com/edgemicro-kubernetes/edgemicro-k8/releases/download/${EDGEMICRO_VERSION}/${NAME}.tar.gz"
echo "Downloading $NAME from $URL ..."
curl -L "$URL" | tar xz

# TODO: change this so the version is in the tgz/directory name (users trying multiple versions)
echo "Downloaded into $NAME:"
ls $NAME
BINDIR="$(cd $NAME/bin; pwd)"
echo "Add $BINDIR to your path; e.g copy paste in your shell and/or ~/.profile:"
echo "export PATH=\"\$PATH:$BINDIR\""