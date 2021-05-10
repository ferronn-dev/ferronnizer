#!/bin/sh
set -e
mkdir old
unzip -q -d new Ferronnizer.zip
if gh release download -D rel latest; then
  echo 'Checking existing release...'
  unzip -q -d old rel/Ferronnizer.zip
  if diff -qrN old new; then
    echo 'No difference since last release.'
    exit 0
  fi
  echo 'Deleting existing release...'
  gh release delete latest
fi
echo 'Creating new release...'
(echo '```'; git diff --no-index --stat=120 old new || true; echo '```') > /tmp/thediff.md
gh release create -t latest -F /tmp/thediff.md latest
gh release upload latest Ferronnizer.zip
echo 'Moving latest tag...'
git tag -f latest
git push -f origin latest
echo 'Done.'
