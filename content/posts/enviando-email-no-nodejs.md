---
title: Enviando e-mails com o Node.js
date: 2015-03-15 20:11
author_name: Alan Hoffmeister
author_url: https://twitter.com/alan_hoff
gravatar: 6350d3781efe9d1a3a88542771ee39d4
image: email.jpg
collection: posts
template: post.html
---

Muitos sistemas dependem de envio de e-mails, sejam estes transacionais
(ativação de conta, confirmação de e-mail, etc..) ou para e-mail marketing. Esta
tarefa pode ser facilmente executada no Node.js quando utilizamos alguns pacotes
bem populares da plataforma.
<!--more-->

### O responsável

Para iniciar com o envio de e-mails na plataforma Node.js, vamos utilizar um dos
módulos mais famosos e testados, o [Nodemailer][0], com ele é fácil enviar 
mensagens em unicode, com HTML ou texto puro, com anexos e até imagens
embarcadas no próprio e-mail.

Ele já vem com suporte a vários servidores SMTP, incluindo o Gmail, Hotmail,
Zoho, SendGrid, FastMail, Mandrill, Amazon SES, [entre outros][1]... Tudo está
bem documentado e com exemplos de como fazer.

### O básico, enviando um e-mail

Nos exemplos que seguem nesta postagem vamos utilizar sempre o Gmail, porém
poderia ser qualquer servidor SMTP. Para enviar um e-mail basta poucas linhas:

```javascript
var nodemailer = require('nodemailer');

// O primeiro passo é configurar um transporte para este
// e-mail, precisamos dizer qual servidor será o encarregado
// por enviá-lo:
var transporte = nodemailer.createTransport({
  service: 'Gmail', // Como mencionei, vamos usar o Gmail
  auth: {
    user: 'usuario@gmail.com', // Basta dizer qual o nosso usuário
    pass: 'shhh!!'             // e a senha da nossa conta
  } 
});

// Após configurar o transporte chegou a hora de criar um e-mail
// para enviarmos, para isso basta criar um objeto com algumas configurações
var email = {
  from: 'usuario@gmail.com', // Quem enviou este e-mail
  to: 'alanhoffmeister@gmail.com', // Quem receberá
  subject: 'Node.js ♥ unicode',  // Um assunto bacana :-) 
  html: 'E-mail foi enviado do <strong>Node.js</strong>' // O conteúdo do e-mail
};

// Pronto, tudo em mãos, basta informar para o transporte
// que desejamos enviar este e-mail
transporte.sendMail(email, function(err, info){
  if(err)
    throw err; // Oops, algo de errado aconteceu.

  console.log('Email enviado! Leia as informações adicionais: ', info);
});
```

### Anexando as coisas

É muito fácil enviar e-mails simples, somente com texto ou HTML, mas o que
acontece quando precisamos anexar documentos, fotos e etc? Continua igualmente
simples :-)

```javascript
var email = {
  from: 'usuario@gmail.com',
  to: 'alanhoffmeister@gmail.com',
  subject: 'Veja os anexos',
  html: 'Estou mandando alguns anexos para testar.'
  attachments: [{ // Basta incluir esta chave e listar os anexos
    filename: 'boleto.pdf', // O nome que aparecerá nos anexos
    path: 'servidor/boletos/boleto_gerado1234.pdf' // O arquivo será lido neste local ao ser enviado
  }]
};

// Pronto, basta enviar!
transporte.sendMail(email, function(err){
  if(err)
    throw err; // Oops, algo de errado aconteceu.

  console.log('Email enviado!');
});
```

### Utilizando o seu SMTP

É muito comum que algumas pessoas tenham seus próprios servidores, ou possuam
e-mails em serviços que ainda não estejam configurados no Nodemailer, como o
HostGator, UOL Host, Locaweb, etc... Para poder utilizar estes servidores basta
configurar o `transporte` exatamente como você configuraria em um Outlook ou
Thunderbird da vida.

```javascript
var transporte = nodemailer.createTransport({
  host: 'mail.www15.locaweb.com.br',
  port: '587',
  secure: true,
  auth: {
    user: 'usuario@seusistema.com',
    pass: 'shhh!!'
  } 
});
```

Para verificar quais os serviços que já estão pré configurados no Nodemailer,
basta ler o conteúdo [deste link][1].

### Uma simples mailing list

Agora que já sabemos como enviar e-mail, criar um sistema que enviar uma
notificação para todos nossos usuários deve ser muito fácil, ainda mais
se usarmos o [handlebars][3] para tornar o e-mail um pouco mais pessoal.

```javascript
var hbs = require('handlebars');
var nodemailer = require('nodemailer');

// Criamos nosso transporte
var transporte = nodemailer.createTransport({
  service: 'Gmail',
  auth: {
    user: 'usuario@gmail.com',
    pass: 'shhh!!'
  } 
});

// Criamos um template bacana para nosso e-mail, com algumas variáveis
// para deixar o mesmo bem pessoal.
var template = hbs.compile('' + 
  '<h1>Olá {{nome}} {{sobrenome}}!</h1>' +
  '<p>É com grande prazer que venho dizer oi!</p>' +
  '<small>Clique <a href="http://seusistema.com.br?desinscrever={{email}}">aqui</a> para desinscrever-se.</small>' +
  '');

// Algumas configurações padrões para nossos e-mails
var config = {
  remetente: 'SeuSistema <contato@seusistema.com.br>',
  assunto: 'Temos uma super oferta para você!'
};

// Agora só falta uma lista de usuários para enviar
var usuarios = [
  {
    nome: 'Alan',
    sobrenome: 'Hoffmeister',
    email: 'alanhoffmeister@gmail.com'
  },
  {
    nome: 'Fulado',
    sobrenome: 'Silva',
    email: 'fulano@silva.com'
  },
  {
    nome: 'Mariazinha',
    sobrenome: 'Jenovéva',
    email: 'mari@hotmail.com'
  }
];

// Criamos uma função recursiva para enviar todos os e-mails
function enviar(i){
  var usuario = usuarios[i]; // Pegamos o usuário da vez
 
  if(!usuario) // Se usuários for false (undefined), significa que a array já terminou
    return console.log('Acabamos de enviar!'); // O return funciona como um break

  // Passamos as variáveis para nosso template
  var html = template(usuario);

  // Hora de disparar o e-mail usando as configurações pré
  // definidas e as informações pessoas do usuário
  transporte.sendMail({
    from: config.remetente,
    to: usuario.email,
    subject: config.assunto,
    htm: html
  }, function(err){

    if(err)
      throw err;

    console.log('E-mail para %s enviado!', usuario.email);

    // Enviamos um e-mail para o próximo da fila incrementando
    // o número que recebemos nesta função
    enviar(++i);
  });
};

// Precisamos chamar a função que criamos
// passando o primeiro lugar da fila no array
enviar(0);
```

Com este exemplo, deve ser muito trivial implementar algo dinâmico que recebe
os usuários e suas informações diretamente de um banco de dados.

### Dores de cabeça

Se você está começando agora neste assunto de enviar e-mails prepare-se para
algumas dores de cabeça. Servidores gratuitos aplicam limites rigorosos,
justamente, para evitar spammers espertinhos, então se você já está pensando
em enviar um e-mail usando aquela lista CSV com 5 mil e-mails guardada há anos
pode tirar seu cavalinho da chuva, certamente irá bater em alguma limitação
do seu serviço de e-mail.

Serviços pagos como o SendGrid ou o Amazon SES podem trazer um limite um pouco
maior, mas seu endereço ainda corre o risco de entrar para uma [blacklist][3]
caso haja denúncias (clicar no botão "Spam") por parte dos destinatários. Se
isso acontecer, seus e-mails podem ser rejeitados automaticamente pelos
servidores (Gmail, Hotmail, etc..) ou na melhor das hipóteses ele pode cair
diretamente na pasta de lixo eletrônico sem que o destinatário saiba de nada.

Sempre siga as duas regras de ouro: 

  * Contrate um serviço de envio (SendGrid, Amazon SES) ou tenha seu próprio
  servidor.
  * Não envie nenhum e-mail que o usuário não esteja esperando receber.


[0]: https://github.com/andris9/Nodemailer
[1]: https://github.com/andris9/nodemailer-wellknown#supported-services
[2]: https://github.com/andris9/Nodemailer#attachments
[3]: http://wiki.locaweb.com.br/pt-br/Blacklist_/_Lista_Negra
