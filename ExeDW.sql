--NOMES: Bernardo Couto Pereira e José Arcangelo

create table clientes(
cliente_id serial,
nome varchar(255),
endereco varchar(255),
cidade varchar(255),
estado char(2),
primary key(cliente_id)
);

create table Centros(
centro_id serial,
nome varchar(255),
endereco varchar(255),
cidade varchar(255),
estado char(2),
primary key(centro_id)
);

create table pedidos (
pedido_id serial,
data_pedido date,
cliente_id int,
centro_saida_id int,
centro_destino_id int,
quantidade int,
valor_total int,
primary key(pedido_id),
foreign key(cliente_id) references clientes(cliente_id)

);


create table Entregas(
entrega_id serial,
pedido_id int,
data_saida date,
data_chegada date,
quilometragem int,
primary key(entrega_id),
foreign key(pedido_id) references pedidos(pedido_id)

);

--MODELO/DIAGRAMA: FOI IDENTIFICADO QUE VARIOS DADOS DA TABELA PEDIDOS E DA TABELA ENTREGAS SERIAM MELHOR SEREM COLOCADAS DIRETAMENTE NA TABELA DE FATOS, ENQUANTO OS DADOS DA TABELA DE CENTROS, 
--JUNTO A UMA SK E VALIDACAO FORAM ADICIONADAS A TABELA DE DIMENÇÕES dim_centros, OS DADOS DA TABELA CLIENTE FORAM ADICIONADOS A TABELA DE DIMENSÃO dim_cliente (JUNTO A UMA SK E UMA VALIDAÇÃO)
-- E A TABELA DE DIMENSÕES dim_tempo É SIMPLIFICADA EM UMA INSERÇÃO DE DATA QUE SE RELACIONA COM AS DATAS DE CHEGADA E SAIDA QUE FAZEM PARTE DA TABELA DE FATOS


-- Tabelas de dimensoes

create table dim_tempo(
data_id serial,
data_ocorrido date,
primary key(data_id)

);

create table dim_cliente(
cliente_id int,
sk int,
nome varchar(255),
endereco varchar(255),
data_registro date,
data_fim date,
validacao boolean,
primary key(cliente_id)

);


create table dim_centros(
centro_id int,
sk int,
nome varchar(255),
endereco varchar(255),
data_registro date,
cidade varchar(255),
estado char(2),
validacao boolean,
primary key(centro_id)
);

--Tabela de fatos

create table fato_Entregas(
pedido_id int,
cliente_id int,
centro_id int,
data_pedido_id int,
data_saida_id int,
data_chegada_id int,
quilometragem int,
quantidade int,
valor_total int,

primary key(pedido_id, cliente_id, centro_id),
foreign key(cliente_id) references dim_cliente(cliente_id),
foreign key(centro_id) references dim_centros(centro_id),
foreign key(data_saida_id) references dim_tempo(data_id),
foreign key(data_chegada_id) references dim_tempo(data_id)

);


--POPULANDO TABELAS:

-- Populando a tabela dim_tempo
INSERT INTO dim_tempo (data_ocorrido) VALUES ('2023-11-01');
INSERT INTO dim_tempo (data_ocorrido) VALUES ('2023-11-02');
INSERT INTO dim_tempo (data_ocorrido) VALUES ('2023-11-03');

-- Populando a tabela dim_cliente
INSERT INTO dim_cliente (cliente_id, sk, nome, endereco, data_registro, data_fim, validacao) 
VALUES (1, 1001, 'Cliente A', 'Rua A, 123', '2023-01-01', NULL, TRUE);
INSERT INTO dim_cliente (cliente_id, sk, nome, endereco, data_registro, data_fim, validacao) 
VALUES (2, 1002, 'Cliente B', 'Rua B, 456', '2023-02-15', NULL, TRUE);

-- Populando a tabela dim_centros
INSERT INTO dim_centros (centro_id, sk, nome, endereco, data_registro, cidade, estado, validacao)
VALUES (1, 2001, 'Centro A', 'Avenida C, 789', '2023-03-01', 'São Paulo', 'SP', TRUE);
INSERT INTO dim_centros (centro_id, sk, nome, endereco, data_registro, cidade, estado, validacao)
VALUES (2, 2002, 'Centro B', 'Avenida D, 1011', '2023-03-15', 'Rio de Janeiro', 'RJ', TRUE);

-- Populando a tabela fato_Entregas
INSERT INTO fato_Entregas (pedido_id, cliente_id, centro_id, data_pedido_id, data_saida_id, data_chegada_id, quilometragem, quantidade, valor_total)
VALUES (1, 1, 1, 1, 2, 3, 500, 10, 2000);
INSERT INTO fato_Entregas (pedido_id, cliente_id, centro_id, data_pedido_id, data_saida_id, data_chegada_id, quilometragem, quantidade, valor_total)
VALUES (2, 2, 2, 2, 1, 2, 750, 5, 1250);

--3

--CONSULTA TOTAL DE PRODUTOS TRANSPORTADOS

select sum(quantidade) AS total_produtos_transportados
from fato_Entregas;

--CONSULTA TEMPO DE ENTREGA
   
   
 select
 fato_Entregas.pedido_id,
 fato_Entregas.cliente_id,
 fato_Entregas.centro_id,
 dim_tempo_chegada.data_ocorrido as data_chegada,
 dim_tempo_saida.data_ocorrido as data_saida,
 dim_tempo_chegada.data_ocorrido - dim_tempo_saida.data_ocorrido as tempo_total_de_entrega_dias
 from fato_Entregas
 inner join dim_tempo dim_tempo_saida on fato_Entregas.data_saida_id = dim_tempo_saida.data_id
 inner join dim_tempo dim_tempo_chegada on fato_Entregas.data_chegada_id = dim_tempo_chegada.data_id;

--CONSULTA MEDIA DE TEMPO DE UM PEDIDO

select
AVG(dim_tempo_chegada.data_ocorrido - dim_tempo_saida.data_ocorrido) AS tempo_medio_entrega_dias
from    fato_Entregas
inner join    dim_tempo dim_tempo_saida ON fato_Entregas.data_saida_id = dim_tempo_saida.data_id
inner join    dim_tempo dim_tempo_chegada ON fato_Entregas.data_chegada_id = dim_tempo_chegada.data_id;
   
   
--CONSULTA CUSTO MEDIO POR QUILOMETRO

select
AVG(fato_Entregas.valor_total / fato_Entregas.quilometragem) AS custo_medio_por_quilometro
from fato_Entregas;   
   
   
