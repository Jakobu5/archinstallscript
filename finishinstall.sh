#!/usr/bin/env bash
set -euxo pipefail

loadkeys de-latin1

systemctl start dhcpcd
systemctl enable dhcpcd

pacman -Syyuu cmatrix
