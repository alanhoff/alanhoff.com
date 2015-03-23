---
title: Autenticação de dois fatores no Node.js
date: 2015-03-22 23:00
author_name: Alan Hoffmeister
author_url: https://twitter.com/alan_hoff
gravatar: 6350d3781efe9d1a3a88542771ee39d4
image: security.jpg
collection: posts
template: post.html
---

Não é mais tão complicado implementar um sistema de autenticação de dois 
fatores, e usando ferramentas práticas não irá custar nenhum centavo a mais no
seu cartão de crédito para deixar os seus usuários (e seu sistema) mais seguros.
<!--more-->

Para quem ainda não conhece, a [autenticação de dois fatores (2FA)][0] nada mais
é do que um login que necessita uma informação adicional à senha do usuário.
Alguns sistemas, como o Google por exemplo, podem enviar uma senha ao celular
do usuário e pedir que que o mesmo digite os caracteres recebidos. O problema
com o método de SMS é que pode sair caro para algumas empresas, ainda mais com
o dólar em seu estado atual.

### TOTP pode ser a salvação

Um mecanismo muito inteligente e muito fácil de implementar são as chamadas
[One Time Passwords][1], que nada mais é do que um hash simples gerado a
partir de uma chave secreta compartilhada. Neste post vamos focar em uma
derivação do OTP chamada [TOTP][2], a diferença entre o algorítmo OTP é que
nesta derivação acrescentamos o [Unix Epoc][3], que é uma medida de tempo. 
Assim podemos automaticamente gerar uma senha sincronizada com todos que possuem 
a chave secreta e um relógio sincronizado, esta senha também pode expirar 
automaticamente dentro de um intervalo de tempo pré estabelecido.

Além de ter uma implementação mais rápida e barata que o envio de SMS, o TOTP
também conta com aplicativos mobile gratuitos para que os usuários gerenciem
suas senhas descartáveis entre todos os sites que possuem esta funcionalidade
habilitada, o aplicativo que usaremos aqui é o [Google Autenticator][4].

### Mão na massa

Não basta ler um monte de informações e não aplicar na prática, hoje vamos
utilizar o aplicativo Google Autenticator e o pacote [speakeasy][5] do Node.js,
essas duas ferramentas conseguem gerar as TOTPs a partir de uma chave secreta.
Não esqueça que o seu aparelho de celular e o seu computador precisam estar 
com os relógios sincronizados, o que é 99,9% dos casos, mesmo assim vale o
aviso :-)

```javascript
var speakeasy = require('speakeasy');

// Vamos gerar uma chave secreta e um link para que o usuário possa
// escanear o QR code e fazer o setup da TOTP no seu device
var secret = speakeasy.generate_key({
  google_auth_qr: true // Avisa o speakeasy que queremos um QRCode também
});

console.log('Acesse este link e escaneie o QRCode com o Google Authenticator:\n%s', secret.google_auth_qr);

// Neste exemplo, vamo apenas mostrar na tela o código
// gerado, ele deve bater com o código gerado pelo seu aparelho
var codigo = null;

setInterval(function() {

  // Com apenas um comando podemos gerar a senha TOTP, basta utilizar
  // a mesma chave secreta gerada anteriormente
  var totp = speakeasy.totp({
    key: secret.ascii
  });

  // Cada vez que nossa senha alterar, mostramos na tela
  if (totp !== codigo)
    console.log('Sua nova senha é: %s', totp);

  codigo = totp;
}, 100);
```

Se você continuar olhando o seu terminar, verá que sua senha troca a cada 30
segundos, o mesmo também irá acontecer no seu Google Authenticator caso você
tenha feito o setup usando o QRCode.

Agora não faltam mais motivos para você implementar uma autenticação de dois
fatores segura, robusta e barata em seu sistema, seus usuários agradecerão :-)

[0]: https://en.wikipedia.org/wiki/Two_factor_authentication
[1]: https://pt.wikipedia.org/wiki/Senha_descart%C3%A1vel
[2]: https://en.wikipedia.org/wiki/Time-based_One-time_Password_Algorithm
[3]: https://pt.wikipedia.org/wiki/Era_Unix
[4]: https://support.google.com/accounts/answer/1066447?hl=pt-BR
[5]: https://github.com/markbao/speakeasy
