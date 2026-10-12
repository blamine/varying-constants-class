#!/usr/bin/env bash
# usage: tools/make_patch.sh <arbre_amont> <arbre_modifie> > variante/class.patch
set -uo pipefail
PRISTINE="$1"; MODIFIED="$2"
status=0
for d in include main source python/cclassy.pxd; do
  [ -e "$MODIFIED/$d" ] || continue
  diff -ruN \
    --exclude='*.o' --exclude='*.a' --exclude='*.so' --exclude='*.mod' \
    --exclude='__pycache__' --exclude='*.pyc' \
    "$PRISTINE/$d" "$MODIFIED/$d"
  s=$?
  [ "$s" -gt "$status" ] && status=$s
done
[ "$status" -le 1 ] || exit "$status"
