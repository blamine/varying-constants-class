#!/usr/bin/env bash
# build.sh, reconstruit l'arbre CLASS modifie de la variante 1GNT-alpha-BBN
# usage: ./build.sh [repertoire_de_destination]
set -euo pipefail

CLASS_TAG="v3.2.0"
CLASS_COMMIT="aa92943e4ab86b56970953589b4897adf2bd0f99"

HERE="$(cd "$(dirname "$0")" && pwd)"
DEST="${1:-$HERE/class_build}"

if [ -e "$DEST" ]; then
  echo "error, $DEST existe deja" >&2
  exit 1
fi

echo "== clone de CLASS $CLASS_TAG =="
git clone --depth 1 --branch "$CLASS_TAG" \
  https://github.com/lesgourg/class_public.git "$DEST"

cd "$DEST"
got="$(git rev-parse HEAD)"
if [ "$got" != "$CLASS_COMMIT" ]; then
  echo "warning, HEAD = $got" >&2
  echo "         attendu  $CLASS_COMMIT" >&2
  echo "         le tag amont a peut-etre bouge, le patch peut echouer" >&2
fi

echo "== application du patch =="
patch -p1 < "$HERE/class.patch"

echo "== table BBN de la variante =="
cp "$HERE/bbn/sBBN_lambda_G.dat" external/bbn/

echo "== compilation =="
make -j class

echo
echo "binaire, $DEST/class"
echo "essai,   cd $DEST && ./class $HERE/ini/<fichier>.ini"
