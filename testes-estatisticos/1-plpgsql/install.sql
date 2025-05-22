--set PGPASSWORD=inicial&& psql -U postgres -h localhost -p 5432 -d db_mestrado -f "C:\Meus Projetos\mestrado-dissertacao\testes-estatisticos\1-plpgsql\install.sql" -L "C:\Users\aaoliveira\Desktop\log.log" >  "C:\Users\aaoliveira\Desktop\teste.log"

set client_encoding = 'UTF8';
set client_min_messages to warning;

\ir 1-create_table.sql
\ir 2-inserts.sql
\ir 3-fc_simula_sorteio.sql
\ir 4-fc_obtem_classificacao_universal_sorteio.sql
\ir 5-pc_sorteios_continuos.sql
