---
title: PostgreSQL, MySQL, MariaDB, SQLite e MSSQL no Node.js
date: 2015-04-27 23:32
author_name: Alan Hoffmeister
author_url: https://twitter.com/alan_hoff
gravatar: 6350d3781efe9d1a3a88542771ee39d4
image: sql.jpg
collection: posts
template: post.html
---

Você sabia que também é possível utilizar o Node.js com as bases de dados mais
utilizadas do mundo? Não só de NoSQL vive o ecossistema de Node.js, existem
pacotes prontos para que você utilize os bancos que você já possue rodando!
<!--more-->

É um fato que a plataforma Node.js cresceu ao redor de bancos mais atuais como
o MongoDB, onde a possibilidade de rodar JavaScript no banco de dados foi um dos
fatores principais neste acontecimento, porém isto não quer dizer que não
podemos utilizar bancos SQL ou que nossas ferramentas não estão aptas à
produção com estas bases, muito pelo contrário.

### Sequelize

O [Sequelize][0] é um ORM completo para bancos de dados SQL, incluíndo o
PostgreSQL, MySQL, MariaDB, SQLite e MSSQL, estre suas features podemo
destacar:

* Definição de schemas
* Sincronização/remoção de schemas
* Associações de 1:1, 1:M e N:M
* Promises
* Hooks/callbacks/eventos de ciclo de vida
* Transações
* Migrações
* Linha de comando

Neste post pretendo abordar algumas das utilizações básicas do Sequelize, assim
você poderá sair daqui e desenvolver uma aplicações utilizando as bases que você
já conhece ou migrar aplicações que utilizam SQL em outras plataformas.

### Setup básico

Em todos os nossos exemplos utilizaremos o SQLite v3, por se tratar de um banco
portátil sem a necessidade de instalação, portando vamos à instalação
do projeto:

```bash
$ mkdir teste_sequelize
$ cd teste_sequelize
$ npm init # tecle "ENTER" para todas as perguntas para não perder tempo
$ npm install --save sequelize sqlite3
```

Depois destes comandos você terá uma pasta pronta para começar a testar os
códigos que descreverei a seguir.

### Seu primeiro schema

Dentro da pasta que criamos, crie um arquivo chamado `app.js` e insira o
seguinte código dentro:

```javascript
var Sequelize = require('sequelize');

// Precisamos criar uma conexão co o banco de dados atual, o SQLite irá criar
// este arquivo caso o mesmo não exista ainda
var db = new Sequelize('sqlite://db.sqlite');

// Já podemos definir um schema!
var Usuario = db.define('Usuario', {
  nome: Sequelize.STRING,
  sobrenome: Sequelize.STRING,
  senha: Sequelize.STRING
  aniversario: Sequelize.DATE
});

// Para criar esta tabela dentro do banco de dados, precisamos chamar o método
// sync, ele somente irá criar a tabela caso a mesma ainda não exista, isto
// também vale para colunas da tabela que definimos
Usuario.sync().then(function(){
  console.log('Tabela de usuários criada!');
});
```

Ao rodar este código você irá perceber várias coisas que acontecem
*automagicamente*, vou citar algumas delas caso você não tenha notado:

* O Sequelize se encarrega de criar o banco de dados, raramente você precisará
digitar alguma query SQL junto ao código ou abrir um cliente gráfico para
mexer em suas tabelas.
* O método `.sync()` somente irá criar a tabela caso a mesma ainda não exista,
o mesmo vale para as colunas de nossa tabela, este método é seguro de usar pois
nunca irá remover nenhum dado.
* Este ORM trabalha com [promises][1], isto significa que você já terá uma
ferramenta de controle de fluxo assíncrono padronizada.
* Ele já criou os campos `id (INTEGER, KEY AUTOINCREMENT)`, 
`createdAt (DATETIME)` e `updatedAt (DATETIME)`, caso isso seja um problema para
você saiba que existe como [desabilitar estas features][2].
* Toda query que acontece no banco aparece no console para que você entenda o
que está acontecendo e possa debugar erros com mais facilidade. Esta é outra
feature que pode ser [facilmente desabilitada][3].

### Criar, ler, modificar e apagar

Agora que já temos nossa primeira tabela criada, podemos começar a mexer com os
dados dentro dela, para isso vamos criar um usuário, modifica-lo e logo mais
apagar o mesmo.

```javascript
Usuario.create({
  nome: 'Alan',
  sobrenome: 'Hoffmeister',
  senha: '123',
  aniversario: new Date(1989, 9, 10)
}).then(function(usuario){
  // Neste ponto o nosso usuário já está criado no banco de dados
  // verifique o seu terminal para ver qual query o Sequelize executou
  console.log('Usuário inserido!', usuario.get());

  // Agora buscamos por um usuário com o sobrenome 'Hoffmeister', já que
  // este ORM trabalha com promises, basta retornar uma promise aqui
  return Usuario.find({
    where: {
      senha: '123'
    }
  });

}).then(function(usuario){
  // Aqui a pesquisa já terá retonado, vamos modificar este usuário para a 
  // data correta e salvar o mesmo no banco de dados.
  usuario.set({
    aniversario: new Date(1989, 9, 14)
  });

  // Novamente, basta retornar uma promise
  return usuario.save();

}).then(function(usuario){
  // A instância atualizada do usuário está aqui nesta função, podemos
  // agora remover este usuário usando o método destroy
  return usuario.destroy();

}).then(function(){
  console.log('Terminamos de criar, pesquisar, atualizar e excluir!');
});
```

Novamente, dê uma olhada em seu console para estudar minuciosamente as queries
que o Sequelize executou.

### Métodos customizados e hooks

Este é um tópico um pouco mais avançado, mas tenho certeza que todos aqueles
que pretendem administrar um grande banco de dados vai tirar muito proveito de
algumas facilidades que o Sequelize nos proporciona, em especial os métodos
customizados e os hooks.

```javascript
// Vamos modificar um pouco o nosso esquema para que o mesmo crie um hash
// das senhas digitadas em vez de guardá-las de um jeito inseguro
var crypto = require('crypto');
var Usuario = db.define('Usuario', {
  nome: Sequelize.STRING,
  sobrenome: Sequelize.STRING,
  senha: Sequelize.STRING,
  aniversario: Sequelize.DATE
}, {

  // Criamos um método de instância ao declarar valores dentro deste objeto
  instanceMethods: {

    // Vamos criar uma função que nos ajuda a verificar a senha
    verificaSenha: function(senha){
      var hash = crypto.createHash('sha1').update(senha).digest('hex');

      // Agora basta verificar se a senha que passamos para a verificação
      // é a mesma senha que está registrada para este usuário
      return hash === this.get('senha');
    }
  }  

});

// Não basta ter um método para verificar a senha, também queremos que
// o schema crie um hash automaticamente quando um usuário for criado
Usuario.hook('beforeCreate', function(usuario, opts, cb){
  
  // Alteramos o campo "senha" para um hash sha1 da mesma
  usuario.set({
    senha: crypto.createHash('sha1').update(usuario.get('senha')).digest('hex')
  });

  // Chamamos o callback com a instância modificada do usuário
  cb(null, usuario);
});

// Agora basta testar o que acabamos de criar
Usuario.create({
  nome: 'Alan',
  sobrenome: 'Hoffmeister',
  senha: '123',
  aniversario: new Date(1989, 9, 10)
}).then(function(usuario){
  // Verificamos se criou o hash sha1
  console.log('O hash da senha gravada é %s', usuario.get('senha'));

  // Também podemos simular um login, testando uma senha qualquer com a senha
  // gravada no banco de dados através do método que criamos
  var ok = usuario.verificaSenha('senha_diferente');

  console.log('A senha é igual? %s', ok ? 'Sim' : 'Não');

});
```

**ATENÇÃO:** O hash SHA1 demonstrado aqui serve apenas para situações
educacionais, ao guardar senhas no banco de dados utilize algoritmos mais
seguros como o [bcrypt][4] ou o [scrypt][5].

### Transações

Outro ponto fundamental de qualquer base SQL são as queries transacionais, o
Sequelize pode cuidar disto facilmente para você:

```javascript
// Para iniciar uma transação com o Sequelize, basta chamar o método
// .transaction() da instância do seu banco de dados
db.transaction(function(t){
  
  // Vamos transferir dinheiro de um usuário fictício em um schema
  // igualmente fictício
  return Usuario.find(1).then(function(usuario){

    // Retiramos 100 reais do usuário
    usuario.set('dinheiro', usuario.get('dinheiro') - 100)

    return usuario.save({transaction: t})
  }, {transaction: t}).then(function(usuario){

    // Verificamos se a conta dele ainda está positiva
    if(usuario.get('dinheiro') < 0)
      throw new Error('Sem fundos suficientes');
  });

}).then(function(){
  console.log('Dinheiro debitado com sucesso!');
}).catch(function(err){
  console.log('Não foi possível debitar por: %s', err.message);
});
```

Como podemos ver, o `rollback` e o `commit` são gerenciados automaticamente,
basta levantar um erro com o `throw` para que a transação seja revertida ou
não levantar nenhum erro para que a mesma seja aceita e commitada. Para mais
detalhes acesse [este link][6].

### Associações e relações

Utilizar associações e relações no Sequelize também é algo relativamente
trivial:

```javascript
var Animal = db.define('Animal', {/* Seu schema */});
var Tigre = db.define('Tigre', {/* Seu schema */});

// Basta relacionar os schemas, o Sequelize automaticamente adicionará
// o atributo AnimalId que conterá a chave primária do Animal
Tigre.belongsTo(Animal);
```

Você pode ver outros exemplos e uma explicação mais detalhada desta
funcionalidade [neste link][7].

### Conclusão

Não precisamos migrar toda uma aplicação já existente para MongoDB ou iniciar
os estudos em um banco deste gênero para iniciar no mundo do Node.js,
ferramentas de alta qualidade que trabalham com a tecnologia que você já
conhece existem sim para esta plataforma. O que você está esperando?

[0]: http://docs.sequelizejs.com/en/latest
[1]: https://www.promisejs.org
[2]: http://docs.sequelizejs.com/en/latest/docs/models/#configuration
[3]: http://docs.sequelizejs.com/en/1.7.0/docs/usage/#options
[4]: https://www.npmjs.com/package/bcrypt-nodejs
[5]: https://www.npmjs.com/package/scrypt
[6]: http://docs.sequelizejs.com/en/latest/docs/transactions/
[7]: http://docs.sequelizejs.com/en/latest/docs/associations/
