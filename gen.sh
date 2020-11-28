#!/bin/bash

mkdir -p .gen
pushd .gen || exit
if [ -d swift-cdp-domains ]; then
  echo 'repo already cloned.'
  git pull -f
  else
  git clone https://github.com/634750802/swift-cdp-domains.git
fi
popd || exit

swift build --product=ChromeDevtoolProtocolGen -c=release --jobs=4 || exit
.build/release/ChromeDevtoolProtocolGen .gen/swift-cdp-domains || exit

pushd .gen/swift-cdp-domains || exit

git add .
git commit -m "codegen" && git push

popd || exit
