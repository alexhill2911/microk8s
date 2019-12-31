#!/usr/bin/env bash

## Make sure to have root privilege
if [ "$(whoami)" != 'root' ]; then
  echo -e "\e[31m\xe2\x9d\x8c Please retry with root privilege.\e[m"
  exit 1
fi

## Try to locate NVIDIA Linux Driver installer
## `NVIDIA-Linux-x86_64-<VERESION>.run` under current directory
## or `~/Downloads` directory
echo -e "\e[33m\xe2\x8f\xb3 Locating NVIDIA-Linux-x86_64-<VERSION>.run ...\e[m"
INSTALLER="$(find "$PWD" -maxdepth 1 -name 'NVIDIA-Linux-x86_64*\.run' | sort -r | head -1 )"
  if [ "$INSTALLER" = '' ]; then
    echo -e "\e[31m\xe2\x9d\x8c Cannot find NVIDIA-Linux-x86_64-<VERSION>.run under current directory or ~/Downloads\e[m"
    LATEST="$(curl -L https://download.nvidia.com/XFree86/Linux-x86_64 | grep "<span class='dir'>" | tail -n1 | sed -e "s/.*'>//" -e "s/\/<.*//" )"
    if [ -z "$LATEST" ]; then
      echo -e "\e[31m Cannot obtaining latest NVIDIA driver version number ...\e[m"
      echo -e "\e[32m Please Download the latest driver manually\e[m"
      exit 1
    else
      echo -e "\e[32m The latest version of NVIDIA driver is \e[33m${LATEST}\e[m"
      echo -e "\e[32m Dowloading \e[33m${LATEST} ...\e[m"
      curl -O "https://download.nvidia.com/XFree86/Linux-x86_64/${LATEST}/NVIDIA-Linux-x86_64-${LATEST}.run"
      if [ -f "NVIDIA-Linux-x86_64-${LATEST}.run" ]; then
        INSTALLER="NVIDIA-Linux-x86_64-${LATEST}.run"
      fi
    fi
  fi

chmod 755 NVIDIA-Linux*
