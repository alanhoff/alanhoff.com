---
title: Como guardar as senhas dos seus usuários
date: 2015-05-02 19:51
author_name: Alan Hoffmeister
author_url: https://twitter.com/alan_hoff
gravatar: 6350d3781efe9d1a3a88542771ee39d4
image: password.jpg
collection: posts
template: post.html
---

Você jamais deve construir um sistema pensando que o mesmo será à prova de
invasões, bugs, exploits e vulnerabilidade. Pensando desta forma devemos ter
cuidado com as informações pessoais dos usuários deste sistema, incluindo suas
senhas.
<!--more-->

### Seu sistema não é infalível

Imagine que alguma pessoa descubra a senha do seu Gmail, Yahoo! ou Hotmail, se
você for igual a 75% dos internautas provavelmente usará esta mesma senha para o
seu Facebook, Twitter, iCloud, no seu computador pessoal, ou ainda pior: na sua
conta bancária.

Você pode estar pensando que não é tão fácil assim conseguir senhas de usuários,
mas o que aprendemos com o parágrafo anterior é que qualquer sistema mal feito
pode comprometer outros sistemas, até mesmo sistemas de grandes empresas podem
ser afetados, como por exemplo o [Snapchat][0], [Adobe][1], [Groupon][2] ou um
mais recente como o [Dropbox][3], entre outros casos. Se esses dados vazados
contiverem senhas salvas de um jeito errado é muito provável que o atacante
consiga acesso à esta senha e inevitavelmente a outros sites no qual o dono
desta senha está cadastrado.

### NÃO guarde a senha em texto puro no seu banco

Sabemos que precisamos da senha guardada em algum lugar para poder efetuar o
login do usuário, mas guardar a senha sem nenhum tipo de proteção é um ato de
extrema irresponsabilidade.

```sql
INSERT INTO usuarios (nome, email, senha)
    VALUES ('Alan', 'alan@gmail.com', 'alan123');
```

Um atacante com acesso a este banco não terá nenhuma dificuldade em saber qual
a senha dos usuários e poderá tentar utilizar as mesmas em outros sites no mesmo
instante.

### NÃO utilize criptografia bidirecional

Existem dois métodos tradicionais para transformar um texto em algo que é
impossível de ser lido sem a ajuda de um algoritmo específico. O primeiro método
é a criptografia bidirecional, neste tipo de criptografia podemos criptografar 
dados utilizando uma senha única ([simétrica][7]) ou um par de senhas 
([assimétrica][8]).

```javascript
// Pseudocódigo
var senha_usuario = '123';
var chave = 'shhh!';

// Aqui temos uma função que encripta a senha do usuário '123'
// utilizando uma chave que apenas o servidor possui
var encriptado = encriptar(senha, chave);

// Não podemos mais ler esta senha
console.log(encriptado); // dbd014125a4bad51db85f27279f1040a

// Mas podemos desencriptar facilmente utilizando a chave do servidor
console.log(desencriptar(encriptado, chave)); // 123
```

O principal ponto deste método é poder encriptar uma informação e depois
desencriptar a informação criptografada, trazendo assim o texto original.

Por mais forte que alguns algoritmos de encriptação bidirecional sejam, eles 
podem ser inúteis em um cenários onde um banco de dados é comprometido, se o
atacante possui acesso ao banco de dados com as senhas criptografadas é muito
provável que o mesmo também terá acesso ao código ou à chave de criptografia
utilizada na encriptação destas senhas, tornando esse método inútil.

O segundo método de criptografia, e o mais utilizado para guardar senhas de
forma segura é a [criptografia unidirecional][9], também chamada de "mão única".
Este tipo de criptografia dispensa o uso de chaves e por este motivo não podemos
recuperar os dados originais.

```javascript
// Pseudocódigo
var senha = '123';
var hash = md5(senha); // e8d95a51f3af4a3b134bf6bb680a213a
var input = prompt('Digite sua senha', '');

// Para verificar a senha digitadas, precisamos transformar
// ela em um hash e comparar com o hash que já temos guardado
if(md5(input) !== hash){
  alert('Senha não confere!');
} else {
  alert('Senha correta.');
}
```

Como podemos verificar neste pseudocódigo, para saber se o usuário digitou a
senha corretamente, precisamos transformar a mesma em um hash e comparar com um
hash guardado no banco de dados anteriormente durante o cadastro deste usuário.
Se o hash gerado coincidir com o hash guardado, sabemos que a senha digitada
coincide com a senha que o usuário escolheu.

### NÃO utilize MD5

O [MD5 é uma função criptográfica][4] unidirecional que transforma um texto em 
uma informação de 128 bits. Foi utilizado durante muito tempo para guardar as
senhas de forma segura, mas atualmente ele é considerado fraco pois possue uma
[taxa de colisão][5] relativamente alta e é fácil de ser quebrada com o hardware
existente nos dias de hoje, sem contar que já existem [dicionários públicos][6]
com uma infinidade de textos já quebrados.

### NÃO utilize salt fixo

Um outro método muito comum utilizado para proteger as senhas dos usuários, é
utilizar um "sal" (salt) juntamente com o hash da senha.

```javascript
// Pseudocódigo
var senha = '123';
var salt = '_SENHA';
var hash = md5(senha + salt);

console.log(hash); // 83d5ff4186df542b7ad353599fe92bde
```

Este método pode ser utilizado para evitar [ataques de dicionário][10] e
[rainbow tables][11], onde o atacante possui uma lista de hash já computados
com senhas comumente usadas.

Embora inteligente, o salt fixo é falho pois o atacante pode facilmente ajustar
o seu dicionário ou rainbow table utilizando o salt usado pelo sistema. Além do 
mais, dois usuários com a mesma senha ainda terão o mesmo hash no seu banco de 
dados, facilitando a vida do atacante.

Por este motivo é recomendado que cada senha tenha o seu próprio salt, e que
também esse salt seja alterado juntamente com a senha do usuário quando o mesmo
solicitar esta alteração.

### NÃO limite a quantidade de caracteres

Em muitos sites ainda é possível encontrar formulários de cadastro onde existe
um limite muito baixo para a quantidade de caracteres que um usuário pode
escolher no campo da senha. Não imponha limites para este campo mas utilize
uma quantidade máxima de caracteres bem alta, em torno de 160. Senhas muito
longas podem levar a [DoS em algumas circunstâncias][12].

### NÃO invente seu próprio algoritmo

Embora seja tentador para alguns programadores iniciantes, inventar o seu
próprio algoritmo de hash pode levar à algumas vulnerabilidades que você não foi
capaz de imaginar ou prever naquele determinado momento, por isso utilize
métodos e bibliotecas já testadas em produção. Lembre-se da velha história: duas
cabeças pensam melhor que uma.

### NÃO envie a senha do seu usuário por e-mail

Este tópico fala um pouco sobre lógica e menos sobre programação. No final do 
ano passado recebi um e-mail da Oi com os seguintes dizeres:

```text
Parabéns Aln Hoffmeister,

Seu registro para a utilização da rede Oi WiFi foi realizado com sucesso.

Lembramos que este cadastro não consiste na obrigação de pagamentos de taxas de 
serviços, somente se você adquirir algum de nossos produtos.

Para trocar sua senha acesse a área do usuário em http://www.oiwifi.com.br

Dados informados:

Login: alanxxxx
Senha: xxxxxxxxxxxx
```

E lá estava no e-mail, a senha que eu havia escolhido para realizar o login no
sistema deles. Isso me leva a pensar algumas coisas:

1. Minha senha circulou sem proteção pelo sistema deles.
2. Será que estão guardando ela de um jeito correto?
3. E se este e-mail foi logado por algum servidor no meio do caminho?
4. E se alguém acessar minha conta de e-mail enquanto eu não estiver na frente
do computador?

Por estes e outros motivos, não preciso nem mencionar o quão irresponsável esta
pratica é. Sem contar a última vez que esqueci minha senha no McDonald's Clube
da Entrega e ao clicar em "Recuperar Senha", eles mandaram um e-mail **COM A 
MINHA SENHA**.

### UTILIZE algoritmos com ajuste de fator de trabalho

Chega de dizer o que não fazer, vamos começar a pensar agora em métodos eficazes
para proteger suas senhas em seu banco.

Algumas bibliotecas e algoritmos populares possuem um fator de trabalho. Isso
quer dizer que é possível ajustar o tempo, tamanho do hash gerado, ou a 
quantidade de recursos do hardware que será utilizado na hora de computar o 
hash de uma senha.

* [PBKDF2][13]: função criptográfica onde podemos informar um salt, o número de
iterações desejadas e o tamanho da chave derivada a ser criada.
* [bcrypt][14]: gera um hash baseado no [Blowfish][15], podemos alterar o fator
de trabalho deste método especificando o número de rodadas utilizadas para o
hash da senha antes da mesma estar pronta.
* [scrypt][16]: outra função criptográfica que, assim como o PBKDF2, gera uma 
chave derivada. Podemos ajustar o fator de trabalho desta função indicando a 
quantidade de memória que ela deve utilizar para gerar a chave derivada.

Estes algoritmos ajustáveis são fundamentais para a segurança de um sistema
a longo prazo. A cada ano a potência dos hardwares aumentam e com isso diminui
o tempo que um atacante demora para quebrar uma senha, com estes algoritmos
podemos alterar o poder necessário para computar/quebrar a senha juntamente com
a evolução do hardware.

É muito provável que existam bibliotecas que implementam estas tecnologias na 
linguagem/plataforma que você trabalha, por isso é importante que você faça uma
pesquisa e busque as bibliotecas mais atualizadas e utilizadas.

### DESENHE seu sistema para lidar com falhas de segurança

Em um eventual cenário de falha ou roubo de informações, é importante assegurar
que o seu sistema possa continuar rodando de forma mais segura, você poderá
utilizar os seguintes passos:

* Invalide tokens anteriores ao ataque.
* Desabilite a alteração das contados de seus usuários, como a pergunta secreta
ou a autenticação de duas vias.
* Atualize suas funções de proteção, credenciamento e login
* Atualize qualquer chave ou salt que o sistema estiver utilizando
* Force a atualização das senhas no próximo login de todos os usuários
* Entre outras...

Como eu disse anteriormente, não podemos desenvolver um sistema 100% infalível,
mas com toda certeza podemos desenvolver este mesmo sistema pensando em um
eventual cenário como este.

### PESQUISE, aprenda e mantenha-se atualizado

Quem lida com segurança da informação sabe que um dos melhores métodos para
manter-se à frente dos atacantes é ficar por dentro de todas as notícias da
área e buscas aprender sobre os métodos atuais de segurança.

* [How NOT to Store Passwords! - Computerphile](https://www.youtube.com/watch?v=8ZtInClXe1Q)
* [Hashing Algorithms and Security - Computerphile](https://www.youtube.com/watch?v=b4b8ktEV4Bg)
* [OWASP Password Storage Cheat Sheet](https://www.owasp.org/index.php/Password_Storage_Cheat_Sheet)
* [How Safe is Your Password? - Brit Lab](https://www.youtube.com/watch?v=z25UlNNHGTw)
* [Early Data Encryption Software - Tomorrow's World](https://www.youtube.com/watch?v=-h8TRSWiQng)
* [You're Probably Storing Passwords Incorrectly](http://blog.codinghorror.com/youre-probably-storing-passwords-incorrectly/)

[0]: https://lookup.gibsonsec.org
[1]: http://www.zdnet.com/article/find-out-if-your-data-was-leaked-in-the-adobe-hack
[2]: http://risky.biz/sosasta
[3]: http://thenextweb.com/apps/2014/10/14/dropbox-passwords-leak-online-alleged-hack
[4]: https://pt.wikipedia.org/wiki/MD5
[5]: http://www.mathstat.dal.ca/~selinger/md5collision
[6]: http://md5cracker.org/
[7]: https://pt.wikipedia.org/wiki/Algoritmo_de_chave_sim%C3%A9trica
[8]: https://pt.wikipedia.org/wiki/Criptografia_de_chave_p%C3%BAblica
[9]: https://pt.wikipedia.org/wiki/Fun%C3%A7%C3%A3o_de_m%C3%A3o_%C3%BAnica
[10]: https://en.wikipedia.org/wiki/Dictionary_attack
[11]: https://pt.wikipedia.org/wiki/Rainbow_table
[12]: http://arstechnica.com/security/2013/09/16/long-passwords-are-good-but-too-much-length-can-be-bad-for-security
[13]: https://en.wikipedia.org/wiki/PBKDF2
[14]: https://pt.wikipedia.org/wiki/Bcrypt
[15]: https://pt.wikipedia.org/wiki/Blowfish
[16]: https://en.wikipedia.org/wiki/Scrypt
