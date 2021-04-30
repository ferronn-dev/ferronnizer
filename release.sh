#!/bin/sh
set -e
set -x
if gh release download -D rel latest; then
  echo 'Checking existing release...'
  (cd rel && unzip -q Ferronnizer.zip)
  unzip -q Ferronnizer.zip
  if diff -qrN Ferronnizer/ rel/Ferronnizer/; then
    echo 'No difference since last release.'
    exit 0
  fi
  echo 'Deleting existing release...'
  gh release delete latest
fi
echo 'Creating new release...'
gh release create -t latest latest
gh release upload latest Ferronnizer.zip
echo 'Done.'
