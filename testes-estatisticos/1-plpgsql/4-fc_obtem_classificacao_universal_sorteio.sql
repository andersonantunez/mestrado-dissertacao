drop function if exists te.fc_obtem_classificacao_universal_sorteio
(
	in p_id_sorteio te.sorteio.id%type,
	in p_nr_semente te.sorteio.nr_semente%type
);

create or replace function te.fc_obtem_classificacao_universal_sorteio
(
	in p_id_sorteio te.sorteio.id%type,
	in p_nr_semente te.sorteio.nr_semente%type
)
returns table
(
	id_sorteio bigint,
	id_inscricao bigint,
	nm_candidato character varying,
	id_sistema_cotas bigint,
	id_cota_inscricao bigint,
	id_cota_processamento bigint,
	fg_classificado boolean,
	od_cota_universal bigint,
	sq_aleatoria double precision
)
as
$$

	with participantes as
	(
		select
		ocsi.id as id_sorteio_item,
		ocsi.id_sorteio,
		ocsi.id_inscricao,
		ocsi.nm_candidato,
		ocsi.id_sistema_cotas,
		ocsi.id_cota_inscricao,
		ocsi.id_cota_processamento,
		ocsi.fg_ativo
		from
		te.sorteio_item ocsi
		inner join te.sorteio ocs on ocs.id = ocsi.id_sorteio
		where
		ocsi.id_sorteio = p_id_sorteio
	),
	sorteio_realizado as
	(
		select *
		from te.fc_simula_sorteio
		(
			(
				select 
				array_agg
				(
					(
						id_inscricao,
						nm_candidato
					)
					order by 
					id_sorteio,
					id_sorteio_item 
					-- Essa abordagem garante que será considerado a lista pela ordem de gravação. 
					-- Sugere-se que a lista no ato da gravação esteja na ordem alfabética
				)
				from 
				participantes
				where
				fg_ativo -- Somente os candidatos classificados participarao do sorteio
			),
			p_nr_semente
		)
	)
	select
	par.id_sorteio,
	par.id_inscricao,
	par.nm_candidato,
	par.id_sistema_cotas,
	par.id_cota_inscricao,
	par.id_cota_processamento,
	par.fg_ativo,
	row_number() over (order by sor.sq_aleatoria nulls last, sor.nm_candidato) as od_universal, -- Candidatos excluidos vao para o fim da fila sem sequencia aleatoria gerada
	sor.sq_aleatoria
	from
	participantes par
	left join sorteio_realizado sor on sor.id_inscricao = par.id_inscricao;	
	
$$
language sql;

/*
select *
from
te.fc_obtem_classificacao_universal_sorteio
(
	709,
	random() --0.9571715447547398 (original)
);
*/