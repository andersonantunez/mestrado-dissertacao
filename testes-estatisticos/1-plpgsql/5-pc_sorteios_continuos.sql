drop procedure if exists te.pc_sorteios_continuos
(
	in p_id_sorteio te.sorteio.id%type,
	in p_tempo_limite interval -- tempo máximo de execução
);

create or replace procedure te.pc_sorteios_continuos
(
    in p_id_sorteio te.sorteio.id%type,
	in p_tempo_limite interval -- tempo máximo de execução
)
language plpgsql
as
$$
declare
    
	v_nr_sorteio bigint := 1;
    v_rc_simulacao_sorteio te.simulacao_sorteio;
    v_inicio timestamp := clock_timestamp();
	
begin

    loop
        
		-- verifica se o tempo limite foi atingido
        exit when clock_timestamp() - v_inicio >= p_tempo_limite;

        -- atualiza os valores do sorteio
        v_rc_simulacao_sorteio.id_sorteio := p_id_sorteio;
        v_rc_simulacao_sorteio.nr_sorteio := v_nr_sorteio;
        v_rc_simulacao_sorteio.dh_sorteio := clock_timestamp();
        v_rc_simulacao_sorteio.nr_semente := random();

        -- insere o sorteio na tabela sorteio
        insert into te.simulacao_sorteio
        values
		(
			v_rc_simulacao_sorteio.id_sorteio, 
			v_rc_simulacao_sorteio.nr_sorteio, 
			v_rc_simulacao_sorteio.dh_sorteio, 
			v_rc_simulacao_sorteio.nr_semente
		);

        -- insere os resultados do sorteio na tabela resultado
        insert into te.simulacao_sorteio_item
		(
			select
			cus.id_sorteio,
			v_nr_sorteio,
			cus.id_inscricao,
			cus.nm_candidato,
			cus.od_cota_universal
			from 
			te.fc_obtem_classificacao_universal_sorteio
			(
				p_id_sorteio, 
				v_rc_simulacao_sorteio.nr_semente
			) cus
		);

        -- incrementa o número do sorteio
        v_nr_sorteio := v_nr_sorteio + 1;

        -- aguarda um pequeno intervalo para evitar sobrecarga extrema
        perform pg_sleep(0.1);
		
    end loop;

end;
$$;

--call te.pc_sorteios_continuos(709, interval '60 seconds');

/*
select 
nr_sorteio,
to_char(dh_sorteio, 'mi:ss.ms'),
nr_semente
from 
te.simulacao_sorteio 
order by 
nr_sorteio;


select
nr_inscricao,
nm_candidato,
array_to_string(array_agg(od_cota_universal order by nr_sorteio), chr(9))
--array_to_string(array_agg(od_universal||'º' order by nr_sorteio), chr(9))
from 
te.simulacao_sorteio_item
group by
nr_inscricao,
nm_candidato;
*/
