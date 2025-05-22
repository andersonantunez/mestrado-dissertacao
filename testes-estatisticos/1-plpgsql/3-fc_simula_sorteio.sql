drop function if exists te.fc_simula_sorteio
(
	in p_ar_lista anyarray,
	in p_nr_semente sorteio_simulacao.nr_semente%type
);

create or replace function te.fc_simula_sorteio
(
    in p_ar_lista anyarray,
    in p_nr_semente te.simulacao_sorteio.nr_semente%type
)
returns table
(
	id_inscricao bigint,
	nm_candidato character varying,
	sq_aleatoria double precision
)
as
$$
	-- A posição dos participantes no array influencia no resultado
	-- Por isso é fundamental vir em ordem alfabetica
    -- Configura a semente aleatória
    select setseed(p_nr_semente);
	select
	qx.id_inscricao,
	qx.nm_candidato,
	random() as sq_aleatoria
	from 
	unnest(p_ar_lista) as qx
	(
		id_inscricao bigint,
		nm_candidato character varying
	)
	order by 
	sq_aleatoria;
	
$$
language sql;

/*

ERROR:  funções PL/pgSQL não podem aceitar tipo record[]
CONTEXT:  compilação da função PL/pgSQL "fc_simula_sorteio" próximo a linha 1
SQL state: 0A000

Anyarray nao funciona em plpgsql. Somente em sql

select * 
from te.fc_simula_sorteio
(
	(
		select array_agg(q1)
		from
		(
			values
			(70784::bigint, 'Anderson 4'),
			(70785::bigint, 'Anderson 5'),
			(70788::bigint, 'Anderson 8'),
			(70783::bigint, 'Anderson 3'),
			(70787::bigint, 'Anderson 7'),
			(70781::bigint, 'Anderson 1'),
			(70782::bigint, 'Anderson 2'),
			(70786::bigint, 'Anderson 6'),
			(70790::bigint, 'Anderson 10'),
			(70789::bigint, 'Anderson 9')
		) as q1
	),
	random()
);

select * 
from fc_simula_sorteio
(
	(
		select
		array_agg
		(
			(
				id_inscricao,
				nm_candidato
			)
		)
		from
		te.sorteio_item ocsi
		inner join te.sorteio ocs on ocs.id = ocsi.id_sorteio
		where
		ocs.id_oferta_curso = 4770		
	),
	0.9571715447547398
);
*/