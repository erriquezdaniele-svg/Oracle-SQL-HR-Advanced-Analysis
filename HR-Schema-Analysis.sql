-- Trovo il nome del dipartimento (DEPARTMENT_NAME) e la media degli stipendi (SALARY) per ogni dipartimento. 
-- Però, voglio vedere solo i dipartimenti che hanno una media stipendi superiore a 8000 e che si trovano 
-- negli Stati Uniti (COUNTRY_ID = 'US').

select d.department_name, to_char(avg(e.salary), '$99999.99') as salario_medio
from departments d
left outer join employees e
on (d.department_id = e.department_id)
where d.department_id in (select department_id
                            from departments d, locations l
                            where (d.location_id (+) = l.location_id)
                            and l.country_id = 'US')
group by d.department_name
having avg(e.salary) > 8000;

-- Voglio un report che metta a nudo la struttura retributiva dell'azienda. Voglio visualizzare:
-- Il nome e cognome del dipendente.
-- Il nome del suo dipartimento.
-- Il suo stipendio attuale.
-- La media stipendi del suo specifico dipartimento.
-- La differenza tra il suo stipendio e la media del dipartimento.
-- Voglio vedere nel report solo i dipendenti che guadagnano più del doppio della media del loro dipartimento.

select concat(e.first_name || ' ', e.last_name) as nome_cognome,
          d.department_name, e.salary, round(x.media, 2) as "Media",
          round((e.salary - x.media), 2) as differenza
from employees e
left outer join (select department_id, avg(salary) media
                    from employees
                    group by department_id)  x
on (x.department_id = e. department_id)
left outer join departments d
on (d.department_id = x.department_id)
where e.salary > 2*x.media;

-- Scrivo una query che estragga:
-- Il nome del dipartimento.
-- Il nome e cognome del dipendente.
-- Il suo stipendio.
-- Il numero di colleghi nello stesso dipartimento che guadagnano meno di lui.
-- Voglio vedere nel report solo i dipendenti che hanno lo stipendio più alto del loro dipartimento (il "Massimo").
-- Se un dipartimento non ha dipendenti, non deve apparire.

select x.department_name, e.first_name, e.last_name, x.stipendio,
          (select count(*)
          from employees e2
          where e2.department_id = e.department_id
-- questa where è fondamentale per contare esclusivamente nel dipartimento corretto 
          and e2.salary < x.stipendio) as conteggio_inferiori -- sotto query a riga singola nel select
from (select department_id, department_name, max(salary) as stipendio
        from employees 
        join departments
        using (department_id)
        group by department_id, department_name) x -- sottoquery a riga multipla nel from
join employees e
on (e.salary = x.stipendio and e.department_id = x.department_id)
-- questa clausola è fondamentale perche distigue per dipartimento non solo per stipendio

-- Scrivo una query che estragga:
-- Il Nome e Cognome del dipendente in un'unica colonna (es. "Steven King").
-- Il Job ID del dipendente.
-- Il Nome del Dipartimento.
-- Una colonna chiamata "Stato_Anzianità":
-- Dove scrivere 'VETERANO' se il dipendente è stato assunto almeno 5 anni prima del suo manager;
-- Dove scrivere 'RECENTE' se è stato assunto dopo il suo manager;
-- Dove scrivere 'COETANEO AZIENDALE' in tutti gli altri casi.
-- Il Nome e Cognome del Manager.
-- Escludo dal report i dipendenti che lavorano nel dipartimento 'IT' o 'Sales'.
-- Ordino il risultato per data di assunzione del dipendente (dal più anziano).

select concat(e.first_name || ' ', e.last_name) as nome_cognome_impiegato, e.job_id,
          d.department_name, (case
                                                when months_between(e.hire_date, m.hire_date) >= 60 then 'VETERANO'
                                                when e.hire_date > m.hire_date then 'RECENTE'
                                                else 'COETANEO AZIENDALE'
                                                end) stato_anzianita, 
         concat(m.first_name || ' ', m.last_name) nome_cognome_manager
from employees e
left outer join employees m
on (e.manager_id = m.employee_id)
left outer join departments d
on (e.department_id = d.department_id)
where d.department_name not in (select department_name
                                                from departments
                                                where lower(department_name) like '%it%'
                                                or lower(department_name) like '%sales%') -- questa sottoquery potrebbe resitutire valori nulli
-- che comprometterebbero l'esecuzione della query
or d.department_id is null -- quindi si aggiunge questa clausola or per evitarlo
order by e.hire_date desc;

-- Scrivo una query che estragga:
-- Nome e Cognome del dipendente.
-- Nome del Dipartimento.
-- Il suo Stipendio.
-- La Media Aziendale (totale di tutti i dipendenti).
-- Una colonna chiamata "Livello_Costo":
-- 'ALTO': se lo stipendio è superiore alla media del suo dipartimento e superiore alla media aziendale.
-- 'MEDIO': se lo stipendio è superiore alla media aziendale ma inferiore a quella del suo dipartimento.
-- 'BASSO': in tutti gli altri casi.
-- La Differenza tra lo stipendio del dipendente e la media del suo dipartimento (arrotondata a 2 decimali).
-- Esclude i dipendenti che non hanno un manager (i "Top Boss").

select concat(e.first_name || ' ', e.last_name) nome_cognome, d.department_name,
          e.salary, round((select avg(salary) from employees), 2) media_aziendale,
          case
                 when e.salary > (select avg(salary) from employees e2 where e2.department_id = e.department_id) then 'ALTO'
                 when e.salary < (select avg(salary) from employees e2 where e2.department_id = e.department_id) 
                 and e.salary > (select avg(salary) from employees) then 'MEDIO'
                 else 'BASSO'
          end livello_costo,
          round(e.salary - (select avg(salary) from employees e2 where e2.department_id = e.department_id), 2) differnza_stipendio
from employees e
left outer join departments d
on (e.department_id = d.department_id)
where e.manager_id is not null;
-- si potrebbe, per rendere la query piu efficiente utilizzare una inline view cioè calcolare la sottoquery a singola riga 
-- della select in un join da unire alla tabella principale



