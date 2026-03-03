#!/bin/bash
set -e

swift build -c release --disable-sandbox
sudo cp -f .build/release/ISSCli /usr/local/bin/ISSCli

echo "App bundled at /usr/local/bin/ISSCli"
