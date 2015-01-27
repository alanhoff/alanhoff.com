---
title: Compilando o Node.js para sistemas embarcados
date: 2015-01-27 19:00
author_name: Alan Hoffmeister
author_url: https://twitter.com/alan_hoff
gravatar: 6350d3781efe9d1a3a88542771ee39d4
image: embedded.jpg
collection: posts
template: post.html
---

Você sabia que o Node.js pode rodar normalmente dentro da sua Raspbepry Pi ou
da sua BeagleBoard? O único problema é que não é tão fácil quanto os
monoclicadores de "Next, Next, Finish" imaginam.
<!--more-->

Por algum motivo obscuro e desconhecido por minha pessoa, a Joyent não gosta
de disponibilizar binários pré compilados do Node.js para sistemas embarcados,
igual ela faz para o Linux, Windows, Mac e SunOS.. Isso é uma pena pois
facilitaria muito a vida das pessoas que querem se aventurar no mundo dos
sistemas embarcados e construir sistemas dentro de placas do tamanho de um
cartão de crédito.

Muitos tutoriais e recursos que encontramos na internet estão desatualizados
e não são claros quanto ao que fazemos durante o percurso da compilação
deixando aquele ar de "wtf are those magic words", por isso resolvi comentar
um pouco sobre o assunto.

![](/assets/img/posts/wtf.gif)

### Antes de começar

Para que tudo funcione bem precisamos ter certeza que temos todos os requisitos
abaixo:

* Uma placa com processador capaz de interpretar o conjunto de instruções ARMv7
* Ubuntu 14.10 (achou que iríamos compilar algo no Windows?)
* Boa vontade e paciência
* Pacotes `build-essential`, `curl` e `xz-util` instalado no seu sistema.

Caso você não esteja rodando esta versão do Linux, pode tentar com qualquer
outra, tenho certeza que não será complicado. Se tudo der errado, tente
instalar o Ubuntu 14.10 em uma VM.

### O toolchain

Primeiramente crie uma pasta para servir de diretório de trabalho, com o comando
`mkdir node4arm && cd node4arm`. A primeira coisa que precisamos ter em mãos
é o compilador compatível com o processador da placa que usaremos, no meu caso
vou precisar de um compilador com a interface binária (ABI) que compile
instruções para processadores da família ARMv7, então faremos o download.

```bash
curl -s url -s http://archlinuxarm.org/builder/xtools/x-tools7h.tar.xz | tar xvJf -
```

Este comando irá criar uma pasta chamada x-tools7h, dentro da qual exite o
compilador e as ferramentas que precisamos para transformar o nosso código C/++
em instruções binárias.

**Dica:** se o conjunto de informações do processador da sua placa não for ARMv7
ou se você está em dúvida acesse sua placa e em um terminal digite
`less /proc/cpuinfo`, este comando vai mostrar na sua tela informações
importantes sobre o processador da sua placa, depois basta visitar
http://archlinuxarm.org/builder/xtools e baixar a versão correspondente ao seu
processador.

### O Node.js

O próximo passo é baixar o código fonte do Node.js e descompactá-lo, utilize
este comando:

```bash
curl -s http://nodejs.org/dist/v0.10.36/node-v0.10.36.tar.gz | tar zxvf -
```

Usando o comando `cd node-v0.10.36`, entre na pasta para iniciar a configuração
e a compilação.

### Compilando

O último passo é setar algumas variáveis de ambiente, algumas flags e compilar
o binário! Utilize o script abaixo para isso

```bash
# Dizemos onde estão nossos compiladores
export PATH="$(pwd)/../x-tools7h/arm-unknown-linux-gnueabihf/bin:$PATH"
export TOOL_PREFIX="arm-unknown-linux-gnueabihf"
export AR="${TOOL_PREFIX}-ar"
export CC="${TOOL_PREFIX}-gcc"
export CXX="${TOOL_PREFIX}-g++"
export LINK="${TOOL_PREFIX}-g++"
export RANLIB="${TOOL_PREFIX}-ranlib"

# Configuramos o binário que queremos compilar para
# que seja para sistemas com hard float point e sem snapshot
./configure --with-arm-float-abi hard --without-snapshot

# Compilar!
make
```

Note que usamos algumas flags para a configuração da compilação,
`--with-arm-float-abi hard` serve para setarmos a compilação para usar a ABI com
hard float point, enquanto `--whitout-snapshot` serve para desabilitar o serviço
de snapshots da V8, que não é compatível com cross compiling.

Depois de rodar este script, o seu binário estará localizado na pasta
`./out/Release`.

### Bônus

Para automatizar o processo criei um script que pode ser encontrado [aqui][0],
basta rodá-lo em qualquer pasta vazia com permissões de escrita, ele já faz
o download da última versão do Node.js e compila o source com todos os cores
disponíveis na sua máquina. Para executar o script basta executar:

```bash
curl -s https://alanhoff.com/assets/etc/node-latest-armv7-generic.sh | bash
```

[0]: https://alanhoff.com/assets/etc/node-latest-armv7-generic.sh
