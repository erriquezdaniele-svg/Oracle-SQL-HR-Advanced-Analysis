-- Oracle SQL Advanced Analytics Project

-- [QUERY 01] - ANALISI EVOLUTIVA DELLA SPESA SALARIALE PER DECENNIO E DIPARTIMENTO
-- Scopo: Analizzare come la spesa degli stipendi si è evoluta nel tempo, 
-- evidenziando i periodi di maggiore crescita aziendale.

with dati_base as (select nvl(d.department_name, 'Senza Dipartimento') as nome_dipartimento,
                           floor(extract(year from e.hire_date)/10)*10 as decennio,
                           e.salary as salario
                           from employees e
                           left join departments d
                           on (e.department_id = d.department_id))
select *
from dati_base
pivot (sum(salario) 
        for decennio 
        in(1980 as anni_80,
            1990 as anni_90,
            2000 as anni_00))
order by nome_dipartimento;

-- [query 02] - analisi comparativa dei costi e posizionamento salariale
-- scopo: classificare i dipendenti in base al loro impatto economico rispetto alla media 
-- dipartimentale e aziendale utilizzando una inline view per l'efficienza.

select concat(e.first_name || ' ', e.last_name) nome_cognome, 
       d.department_name,
       e.salary, 
       round(x.media_aziendale, 2) media_aziendale,
       case
            when e.salary > x.media_dept and e.salary > x.media_aziendale then 'alto'
            when e.salary < x.media_dept and e.salary > x.media_aziendale then 'medio'
            else 'basso'
       end livello_costo,
       round(e.salary - x.media_dept, 2) differenza_stipendio
from employees e
left outer join departments d
on (e.department_id = d.department_id)
join (select department_id, 
             avg(salary) over (partition by department_id) as media_dept,
             avg(salary) over () as media_aziendale
      from employees) x
on (nvl(e.department_id, -1) = nvl(x.department_id, -1))
where e.manager_id is not null
group by e.first_name, e.last_name, d.department_name, e.salary, x.media_dept, x.media_aziendale
order by e.salary desc;            

-- [query 03] - ricostruzione gerarchica dell'organigramma (hierarchical query)
-- scopo: visualizzare l'intera catena aziendale partendo dai vertici.

select level as grado_gerarchico,
       lpad(' ', 3 * (level - 1)) || e.first_name || ' ' || e.last_name as dipendente_indentato,
       e.job_id,
       prior e.first_name || ' ' || prior e.last_name as responsabile_diretto,
       sys_connect_by_path(e.last_name, ' > ') as percorso_carriera
from employees e
connect by prior e.employee_id = e.manager_id
start with e.manager_id is null
order siblings by e.last_name;

-- [query 04] - analisi comparativa e ranking salariale (window functions)
-- scopo: calcolare pesi percentuali e classifiche interne ai dipartimenti.

select d.department_name,
       e.first_name || ' ' || e.last_name as nominativo,
       e.salary as stipendio,
       -- classifica i dipendenti nel reparto dal piu pagato al meno pagato
       rank() over (partition by e.department_id order by e.salary desc) as posizione_reparto,
       -- calcola la media del reparto senza raggruppare le righe
       round(avg(e.salary) over (partition by e.department_id), 2) as media_reparto,
       -- calcola quanto incide lo stipendio del singolo sul totale del reparto
       round((e.salary / sum(e.salary) over (partition by e.department_id)) * 100, 2) as incidenza_percentuale,
       -- mostra lo stipendio del collega che guadagna subito meno di lui (il "precedente")
       lead(e.salary) over (partition by e.department_id order by e.salary desc) as stipendio_successivo
from employees e
join departments d on (e.department_id = d.department_id)
order by d.department_name, posizione_reparto;

-- [query 05] - data quality, filtering avanzato (exists) e campionamento (rownum)
-- scopo: individuare i dipendenti che non hanno un dipartimento valido (not exists)
-- o quelli che appartengono a dipartimenti attivi (exists), pulendo i dati 
-- e limitando il risultato per campionamento..

select rpad(upper(e.last_name), 15, '*') as cognome_formattato,
       lower(e.email || '@hr.com') as email_bonificata,
       nvl(to_char(e.commission_pct, '0.99'), 'nessuna provvigione') as info_commissione,
       e.salary
from employees e
where exists (
      -- filtro: includo solo dipendenti che appartengono a dipartimenti esistenti
      select 1 
      from departments d 
      where d.department_id = e.department_id
)
  and e.salary > (
      -- sottoquery: stipendio superiore alla media aziendale
      select avg(salary) 
      from employees
)
  and rownum <= 10  -- limitazione: prendo solo i primi 10 record per il sample di test
order by e.salary desc;