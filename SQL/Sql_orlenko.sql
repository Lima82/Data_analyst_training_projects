Задача 1
  
SELECT *
FROM company
WHERE status='closed';

Задача 2
  
SELECT funding_total
FROM company
WHERE country_code='USA' AND category_code='news'
ORDER BY funding_total DESC;

Задача 3
  
SELECT SUM(price_amount)
FROM acquisition
WHERE term_code='cash' AND EXTRACT(YEAR FROM CAST(acquired_at AS date)) IN (2011,2012,2013);

Задача 4
  
SELECT first_name,
       last_name,
       twitter_username
FROM people
WHERE twitter_username LIKE 'Silver%';

Задача 5
  
SELECT *
FROM people
WHERE twitter_username LIKE '%money%' AND last_name LIKE 'K%';

Задача 6
  
SELECT SUM(funding_total),
       country_code
FROM company
GROUP BY country_code
ORDER BY SUM(funding_total) DESC;

Задача 7
  
SELECT funded_at,
       MIN(raised_amount),
       MAX(raised_amount)
FROM funding_round
GROUP BY funded_at
HAVING MIN(raised_amount)!=0 AND MIN(raised_amount)!=MAX(raised_amount);

Задача 8
  
SELECT *,    
   CASE
      WHEN invested_companies>=100 THEN 'high_activity'
      WHEN invested_companies>=20 AND invested_companies<100 THEN 'middle_activity'
      WHEN invested_companies<20 THEN 'low_activity'
   END
FROM fund;

Задача 9
  
SELECT 
    CASE
        WHEN invested_companies>=100 THEN 'high_activity'
        WHEN invested_companies>=20 THEN 'middle_activity'
        ELSE 'low_activity'
    END AS activity,
ROUND(AVG(investment_rounds))
FROM fund
GROUP BY activity
ORDER BY ROUND(AVG(investment_rounds));

Задача 10
  
SELECT country_code,
       MIN(invested_companies),
       MAX(invested_companies),
       AVG(invested_companies)
FROM fund
WHERE EXTRACT(YEAR FROM CAST(founded_at AS date)) BETWEEN 2010 AND 2012
GROUP BY country_code
HAVING  MIN(invested_companies)>0
ORDER BY AVG(invested_companies) DESC, country_code 
LIMIT 10;

Задача 11
  
SELECT p.first_name,
       p.last_name,
       e.instituition
FROM people AS p
LEFT JOIN education AS e ON e.person_id=p.id;

Задача 12
  
SELECT c.name AS company_name,
       COUNT (DISTINCT e.instituition) AS university_name_count
FROM company AS c
LEFT JOIN people AS p ON p.company_id=c.id
LEFT JOIN education AS e ON e.person_id=p.id
GROUP BY c.id
ORDER BY university_name_count DESC
LIMIT 5;

Задача 13
  
SELECT DISTINCT (c.name)
FROM company AS c
RIGHT JOIN  funding_round AS fr ON fr.company_id=c.id
WHERE status='closed'  AND is_first_round=1 AND is_last_round=1
GROUP BY c.name;

Задача 14
  
SELECT DISTINCT(p.id)
FROM people AS p
WHERE p.company_id IN (SELECT DISTINCT (c.id)
                       FROM company AS c
                       RIGHT JOIN  funding_round AS fr ON fr.company_id=c.id
                       WHERE status='closed'  AND is_first_round=1 AND is_last_round=1
                       GROUP BY c.id);

Задача 15
  
SELECT DISTINCT(people_id.id),
       e.instituition
FROM education AS e
INNER JOIN (SELECT DISTINCT(p.id)
            FROM people AS p
            WHERE p.company_id IN (SELECT DISTINCT (c.id)
                                   FROM company AS c
                                   RIGHT JOIN  funding_round AS fr ON fr.company_id=c.id
                                   WHERE status='closed'  AND is_first_round=1 AND is_last_round=1
                                   GROUP BY c.id)) AS people_id ON people_id.id=e.person_id;

Задача 16
  
SELECT DISTINCT(people_id.id),  
       COUNT(e.instituition)
FROM education AS e
INNER JOIN (SELECT DISTINCT(p.id)
            FROM people AS p
            WHERE p.company_id IN (SELECT DISTINCT (c.id)
                                   FROM company AS c
                                   RIGHT JOIN  funding_round AS fr ON fr.company_id=c.id
                                   WHERE status='closed'  AND is_first_round=1 AND is_last_round=1
                                   GROUP BY c.id)) AS people_id ON people_id.id=e.person_id
GROUP BY people_id.id;

Задача 17
  
WITH
previous AS (SELECT DISTINCT(people_id.id),  
            COUNT(e.instituition) AS count
            FROM education AS e
            INNER JOIN (SELECT DISTINCT(p.id)
            FROM people AS p
            WHERE p.company_id IN (SELECT DISTINCT (c.id)
                                   FROM company AS c
                                   RIGHT JOIN  funding_round AS fr ON fr.company_id=c.id
                                   WHERE status='closed'  AND is_first_round=1 AND is_last_round=1
                                   GROUP BY c.id)) AS people_id ON people_id.id=e.person_id
            GROUP BY people_id.id)               
SELECT AVG(count)
FROM previous;

Задача 18
  
WITH
previous AS (SELECT DISTINCT(people_id.id),  
            COUNT(e.instituition) AS count
            FROM education AS e
            INNER JOIN (SELECT DISTINCT(p.id)
            FROM people AS p
            WHERE p.company_id IN (SELECT DISTINCT (c.id)
                                   FROM company AS c
                                   RIGHT JOIN  funding_round AS fr ON fr.company_id=c.id
                                   WHERE name='Facebook'
                                   GROUP BY c.id)) AS people_id ON people_id.id=e.person_id
            GROUP BY people_id.id)               
SELECT AVG(count)
FROM previous;

Задача 19
  
SELECT f.name AS name_of_fund,
       c.name AS name_of_company,
       fr.raised_amount AS amount
FROM funding_round AS fr
INNER JOIN investment AS i ON fr.id = i.funding_round_id
INNER JOIN fund AS f ON i.fund_id = f.id
INNER JOIN company AS c ON fr.company_id = c.id
WHERE EXTRACT(YEAR FROM CAST(fr.funded_at AS date)) BETWEEN 2012 AND 2013 AND c.milestones > 6;

Задача 20
  
SELECT c.name,
       a.price_amount,
       co.name,
       co.funding_total,
       ROUND(a.price_amount/co.funding_total)
FROM acquisition AS a
INNER JOIN company AS c ON  c.id=a.acquiring_company_id
INNER JOIN company AS co ON co.id= a.acquired_company_id
WHERE a.price_amount >0 AND  co.funding_total>0
ORDER BY a.price_amount DESC, co.name
LIMIT 10;

Задача 21
  
SELECT c.name,
       EXTRACT(MONTH FROM CAST(fr.funded_at AS date))
FROM company AS c
INNER JOIN funding_round AS fr ON fr.company_id=c.id
WHERE category_code='social' AND fr.raised_amount >0 AND EXTRACT(YEAR FROM CAST(fr.funded_at as DATE )) BETWEEN 2010 AND 2013;

Задача 22
  
WITH 
cause1 AS (SELECT EXTRACT(MONTH FROM CAST(fr.funded_at AS date)) AS invest_month,
                  COUNT(DISTINCT(f.id)) AS count_funds               
           FROM fund AS f
           INNER JOIN investment as i ON i.fund_id=f.id 
           INNER JOIN funding_round AS fr ON i.funding_round_id = fr.id
           WHERE f.country_code='USA' AND EXTRACT(YEAR FROM CAST(fr.funded_at AS date)) BETWEEN 2010 AND 2013
           GROUP BY invest_month),
cause2 AS (SELECT EXTRACT(MONTH FROM CAST(a.acquired_at AS date)) AS invest_month,
                  COUNT(a.acquired_company_id) AS acquired,
                  SUM(a.price_amount) AS total_sum  
           FROM acquisition AS a
           WHERE EXTRACT(YEAR FROM CAST(a.acquired_at AS date)) BETWEEN 2010 AND 2013
           GROUP BY invest_month)  
SELECT c1.invest_month,
       c1.count_funds,
       c2.acquired,
       c2.total_sum
FROM cause1 AS c1
INNER JOIN cause2 AS c2 ON  c1.invest_month=c2.invest_month;

Задача 23
  
WITH
inv_2011 AS(SELECT AVG(c.funding_total) AS avg_sum_2011,
                   c.country_code AS country
            FROM company AS c
            WHERE EXTRACT(YEAR FROM CAST (c.founded_at AS date))=2011
            GROUP BY country, EXTRACT(YEAR FROM CAST (c.founded_at AS date))
            ORDER BY avg_sum_2011 DESC),  
inv_2012 AS(SELECT AVG(c.funding_total) AS avg_sum_2012,
                   c.country_code AS country
            FROM company AS c
            WHERE EXTRACT(YEAR FROM CAST (c.founded_at AS date))=2012
            GROUP BY country, EXTRACT(YEAR FROM CAST (c.founded_at AS date))
            ORDER BY avg_sum_2012 DESC),
inv_2013 AS(SELECT AVG(c.funding_total) AS avg_sum_2013,
                   c.country_code AS country
            FROM company AS c
            WHERE EXTRACT(YEAR FROM CAST (c.founded_at AS date))=2013
            GROUP BY country, EXTRACT(YEAR FROM CAST (c.founded_at AS date))
            ORDER BY avg_sum_2013 DESC)
SELECT inv_2011.country,
       inv_2011.avg_sum_2011,
       inv_2012.avg_sum_2012,
       inv_2013.avg_sum_2013
FROM inv_2011 
INNER JOIN inv_2012 ON inv_2011.country=inv_2012.country
INNER JOIN inv_2013 ON inv_2012.country=inv_2013.country
ORDER BY avg_sum_2011 DESC;
