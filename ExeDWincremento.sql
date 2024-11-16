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

--INSERINDO DADOS

INSERT INTO clientes (nome, endereco, cidade, estado) VALUES 
('Maria Silva', 'Rua das Flores, 123', 'São Paulo', 'SP'),
('João Pereira', 'Avenida Central, 456', 'Rio de Janeiro', 'RJ'),
('Ana Costa', 'Rua dos Pássaros, 789', 'Belo Horizonte', 'MG'),
('Pedro Souza', 'Rua Nova, 101', 'Salvador', 'BA'),
('Fernanda Lima', 'Avenida das Árvores, 202', 'Curitiba', 'PR');

INSERT INTO Centros (nome, endereco, cidade, estado) VALUES 
('Centro de Distribuição A', 'Rua Logística, 100', 'São Paulo', 'SP'),
('Centro de Distribuição B', 'Avenida Expresso, 200', 'Rio de Janeiro', 'RJ'),
('Centro de Distribuição C', 'Estrada das Cargas, 300', 'Belo Horizonte', 'MG'),
('Centro de Distribuição D', 'Rua Rápida, 400', 'Salvador', 'BA'),
('Centro de Distribuição E', 'Avenida Transporte, 500', 'Curitiba', 'PR');

INSERT INTO pedidos (data_pedido, cliente_id, centro_saida_id, centro_destino_id, quantidade, valor_total) VALUES 
('2024-11-01', 1, 1, 2, 50, 500),
('2024-11-02', 2, 2, 3, 30, 300),
('2024-11-03', 3, 3, 4, 20, 200),
('2024-11-04', 4, 4, 5, 40, 400),
('2024-11-05', 5, 5, 1, 60, 600);

INSERT INTO Entregas (pedido_id, data_saida, data_chegada, quilometragem) VALUES 
(1, '2024-11-02', '2024-11-03', 500),
(2, '2024-11-03', '2024-11-04', 300),
(3, '2024-11-04', '2024-11-05', 400),
(4, '2024-11-05', '2024-11-06', 600),
(5, '2024-11-06', '2024-11-07', 700);


--TABELAS DE DIMENSOES

create table dim_tempo(
data_id serial,
data_ocorrido date,
primary key(data_id)

);

create table dim_cliente(
cliente_id int,
sk serial,
nome varchar(255),
endereco varchar(255),
data_registro date,
data_fim date,
validacao boolean,
primary key(cliente_id)

);


create table dim_centros(
centro_id int,
sk serial,
nome varchar(255),
endereco varchar(255),
data_registro date,
cidade varchar(255),
estado char(2),
validacao boolean,
primary key(centro_id)
);

--TABELA DE FATOS

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


--dim_tempo insert

insert into dim_tempo (data_ocorrido) select data_pedido
from pedidos
union select data_saida from entregas
union select data_chegada from entregas;

select * from dim_tempo

--dim_cliente insert

insert into dim_cliente (cliente_id, nome, endereco, data_registro, data_fim, validacao)
select clientes.cliente_id, clientes.nome, clientes.endereco, min(pedidos.data_pedido) as data_registro, null as data_fim, true as validacao
from clientes
left join pedidos on clientes.cliente_id = pedidos.cliente_id
group by clientes.cliente_id, clientes.nome, clientes.endereco;

select * from dim_cliente;

--dim_centros insert

insert into dim_centros (centro_id, nome, endereco, data_registro, cidade, estado, validacao)
select centros.centro_id,centros .nome, centros .endereco, min(pedidos.data_pedido) as data_registro, centros.cidade, centros.estado,true as validacao
from centros 
left join pedidos on centros.centro_id = pedidos.centro_saida_id or centros.centro_id = pedidos.centro_destino_id
group by centros.centro_id, centros.nome, centros .endereco, centros.cidade, centros.estado;

select * from dim_centros;

--tabela de fatos insert


insert into fato_entregas (pedido_id, cliente_id, centro_id, data_pedido_id, data_saida_id, data_chegada_id, quilometragem, quantidade, valor_total)
select pedidos.pedido_id,pedidos.cliente_id,pedidos.centro_saida_id as centro_id,dim_tempo_pedido.data_id as data_pedido_id,dim_tempo_saida.data_id as data_saida_id,dim_tempo_chegada.data_id as data_chegada_id,entregas.quilometragem,pedidos.quantidade,pedidos.valor_total
from pedidos
inner join entregas on pedidos.pedido_id = entregas.pedido_id
inner join dim_tempo dim_tempo_pedido on dim_tempo_pedido.data_ocorrido = pedidos.data_pedido
inner join dim_tempo dim_tempo_saida on dim_tempo_saida.data_ocorrido = entregas.data_saida
inner join dim_tempo dim_tempo_chegada on dim_tempo_chegada.data_ocorrido = entregas.data_chegada;

select * from fato_entregas;




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
   








