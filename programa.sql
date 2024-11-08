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


create table Entregas(
entrega_id serial,
pedido_id int,
data_saida date,
data_chegada date,
quilometragem int,
primary key(entrega_id),
foreign key(pedido_id) references pedidos(pedido_id)

);

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
VALUES (2, 2, 2, 2, 3, 1, 750, 5, 1250);

--CONSULTA








dim_tempo -> pedido_id, data_pedido, data_saida(entrega), data_chegada(entrega), quilometragem(entrega), quantidade, valor_total
dim_ciente   -> sk,cliente_id, nome, endereco , data_registro, data_fim , validacao 
dim_centros  -> sk,centro_id, nome, endereco , data_registro , cidade, estado, validacao

TABELA DE FATOS: pedido_id, cliente_id, centro_id






