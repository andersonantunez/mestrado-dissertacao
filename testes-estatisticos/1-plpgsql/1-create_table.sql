--create database sorteio;

drop schema if exists te cascade;
create schema if not exists te;

create table te.sorteio
(
	id bigserial not null,
	dh_agendamento timestamp with time zone,
	nr_semente double precision,
	primary key (id) -- Nao precisa ser chave composta pois esse id herdado já é unico
);

create table te.sorteio_item
(
	id bigserial not null,
	id_sorteio bigint not null,
	id_inscricao bigint not null, -- Nao possui referencia com inscricao por causa do sorteio avulso
	nm_candidato character varying not null,
	id_sistema_cotas bigint not null,
	id_cota_inscricao bigint not null,
	id_cota_processamento bigint not null,
	fg_ativo boolean not null,
	sq_aleatoria double precision,
	primary key (id),
	foreign key (id_sorteio) references te.sorteio (id),
	unique (id_sorteio, id_inscricao)	
);

create table te.simulacao_sorteio
(
	id_sorteio bigint not null,
	nr_sorteio integer not null,
	dh_sorteio timestamp with time zone,
	nr_semente double precision not null,
	primary key (id_sorteio, nr_sorteio),
	foreign key (id_sorteio) references te.sorteio (id)
);

create table te.simulacao_sorteio_item
(
	id_sorteio bigint not null,
	nr_sorteio integer not null,
	nr_inscricao character varying not null,
	nm_candidato character varying not null,
	od_cota_universal bigint not null,	
	primary key (nr_sorteio, nr_inscricao),
	foreign key (id_sorteio, nr_sorteio) references te.simulacao_sorteio (id_sorteio, nr_sorteio)
);