#!/bin/bash

# check jq installed
if ! command -v jq &> /dev/null; then
    echo "jq installation..."
    sudo apt update && sudo apt install -y jq
fi

# repository info
USER="pocketbase"
REPO="pocketbase"

# using github api to get latest release version
LATEST_RELEASE=$(curl -s https://api.github.com/repos/$USER/$REPO/releases/latest)
VERSION=$(echo $LATEST_RELEASE | jq -r '.tag_name' | sed 's/^v//')

# check host os
ARCH=$(uname -m)
OS=$(uname -s)

if [[ "$OS" == "Linux" && "$ARCH" == "x86_64" ]]; then
    ASSET_KEYWORD="pocketbase_${VERSION}_linux_amd64.zip"
elif [[ "$OS" == "Linux" && "$ARCH" == "aarch64" ]]; then
    ASSET_KEYWORD="pocketbase_${VERSION}_linux_arm64.zip"
elif [[ "$OS" == "Linux" && "$ARCH" == "armv7l" ]]; then
    ASSET_KEYWORD="pocketbase_${VERSION}_linux_armv7.zip"
elif [[ "$OS" == "Darwin" && "$ARCH" == "x86_64" ]]; then
    ASSET_KEYWORD="pocketbase_${VERSION}_darwin_amd64.zip"
elif [[ "$OS" == "Darwin" && "$ARCH" == "aarch64" ]]; then
    ASSET_KEYWORD="pocketbase_${VERSION}_darwin_arm64.zip"
else
    echo "Unsupported OS/ARCH: $OS/$ARCH"
    exit 1
fi

# set download url
DOWNLOAD_URL=$(echo $LATEST_RELEASE | jq -r --arg keyword "$ASSET_KEYWORD" '.assets[] | select(.name == $keyword) .browser_download_url')

if [[ -z "$DOWNLOAD_URL" ]]; then
    echo "Cannot find the download url for $ASSET_KEYWORD"
    exit 1
fi

# download and install
echo "Downloading $DOWNLOAD_URL"
curl -sL $DOWNLOAD_URL -o pocketbase.zip

echo "Installing pocketbase..."
unzip -o pocketbase.zip -d ./pb && rm pocketbase.zip
