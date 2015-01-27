#!/bin/bash

# Compila a última versão estável do Node.js para processadores compatíveis com
# o conjunto de instruções ARMv7
#
# LICENÇA ISC
# Copyright (c) 2015, Alan Hoffmeister <alanhoffmeister@gmail.com>
# Permission to use, copy, modify, and distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

# Configura o bash para parar em caso de erro
set -e

# Conta quantos cores esta máquina tem, assim
# a compilação ocorre mais rapidamente
export CORES=$(cat /proc/cpuinfo | awk '/^processor/{print $3}' | tail -1 )

# Faz download do toolchain e do último Node.js
curl -s http://archlinuxarm.org/builder/xtools/x-tools7h.tar.xz | tar xvJf -
curl -s http://nodejs.org/dist/node-latest.tar.gz | tar zxvf -

# Verifica qual a pasta do Node.js
export NODE_PATH=$(find -maxdepth 1 -type d -name '*node*'| head -n1)

# Exporta variáveis do sistema
export PATH="$(pwd)/x-tools7h/arm-unknown-linux-gnueabihf/bin:$PATH"
export TOOL_PREFIX="arm-unknown-linux-gnueabihf"
export AR="${TOOL_PREFIX}-ar"
export CC="${TOOL_PREFIX}-gcc"
export CXX="${TOOL_PREFIX}-g++"
export LINK="${TOOL_PREFIX}-g++"
export RANLIB="${TOOL_PREFIX}-ranlib"

cd ${NODE_PATH}

# Configuramos o binário que queremos compilar para
# que seja para sistemas com hard float point e sem snapshot
./configure --with-arm-float-abi hard --without-snapshot

# Limpa instalações anteriores
make clean

# Compila
make -j $((CORES+1))

#Pronto
echo "Seu binário para ARMv7 está na pasta ${NODE_PATH}/Release/out"
