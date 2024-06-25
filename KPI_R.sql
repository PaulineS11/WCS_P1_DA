-- Active: 1710172595360@@51.178.25.157@23456@toys_and_models

USE toys_and_models;


/*--------------------------------------------------------*/
/*               ANALYSE DES VENDEURS                     */
/*--------------------------------------------------------*/


/* CA de chaque vendeur par an*/
SELECT emp.lastName AS nom, 
            YEAR(p.`paymentDate`) AS annee,
            sum(p.amount) AS somme_amount
FROM employees emp
INNER JOIN customers c ON `salesRepEmployeeNumber`=`employeeNumber`
INNER JOIN payments p USING(`customerNumber`)
INNER JOIN orders o USING(`customerNumber`)
WHERE p.`paymentDate` IS NOT NULL AND o.`status` <> 'Cancelled'
GROUP BY emp.`lastName`, YEAR(p.`paymentDate`)
ORDER BY nom DESC, annee DESC;

/* CA de chaque vendeur par an et par pays*/
SELECT  emp.lastName AS nom, 
        c.country AS Pays,
        YEAR(p.`paymentDate`) AS annee,
        sum(p.amount) AS somme_amount
FROM employees emp
INNER JOIN customers c ON `salesRepEmployeeNumber`=`employeeNumber`
INNER JOIN payments p USING(`customerNumber`)
INNER JOIN orders o USING(`customerNumber`)
WHERE p.`paymentDate` IS NOT NULL AND o.`status` <> 'Cancelled'
GROUP BY emp.`lastName`, c.country, YEAR(p.`paymentDate`)
ORDER BY Pays ASC, nom DESC, annee DESC;

/* CA de chaque vendeur par an et comparaison à année n-1 + taux d'évolution*/
WITH extr AS (
    SELECT  emp.lastName AS nom, 
            YEAR(p.`paymentDate`) AS annee,
            sum(p.amount) AS somme_amount
    FROM employees emp
    INNER JOIN customers c ON `salesRepEmployeeNumber`=`employeeNumber`
    INNER JOIN payments p USING(`customerNumber`)
    INNER JOIN orders o USING(`customerNumber`)
    WHERE p.`paymentDate` IS NOT NULL AND o.`status` <> 'Cancelled'
    GROUP BY emp.`lastName`, YEAR(p.`paymentDate`)
    ORDER BY nom DESC, annee DESC
)
SELECT e1.nom AS 'Vendeur', e1.annee AS 'Année', e1.somme_amount AS 'Chiffre d\'affaire', e2.annee AS 'Année N-1', e2.somme_amount AS ' Chiffre d\'affaire N-1', (e1.somme_amount-e2.somme_amount)/e2.somme_amount AS 'Taux d\'évolution'
FROM extr e1
INNER JOIN extr e2 ON e1.annee = e2.annee+1 AND e1.nom = e2.nom


/* CA de chaque vendeur par mois et année*/
SELECT  emp.lastName AS nom, 
        YEAR(p.`paymentDate`) AS annee,
        MONTH(p.`paymentDate`) AS mois,
        sum(p.amount) AS somme_amount
FROM employees emp
INNER JOIN customers c ON `salesRepEmployeeNumber`=`employeeNumber`
INNER JOIN payments p USING(`customerNumber`)
INNER JOIN orders o USING(`customerNumber`)
WHERE p.`paymentDate` IS NOT NULL AND o.`status` <> 'Cancelled'
GROUP BY emp.`lastName`, YEAR(p.`paymentDate`), MONTH(p.`paymentDate`)
ORDER BY nom DESC, annee DESC, mois;

/* Chaque mois, les deux vendeurs avec le CA le plus élevé*/
WITH extr AS (
    SELECT  YEAR(o.`orderDate`) AS annee,
            MONTH(o.`orderDate`) AS mois,
            emp.lastName AS nom, 
            sum(p.amount) AS somme_amount
    FROM employees emp
    INNER JOIN customers c ON `salesRepEmployeeNumber`=`employeeNumber`
    INNER JOIN payments p USING(`customerNumber`)
    INNER JOIN orders o USING(`customerNumber`)
    WHERE p.`paymentDate` IS NOT NULL AND o.`status` <> 'Cancelled'
    GROUP BY YEAR(o.`orderDate`),
             MONTH(o.`orderDate`),
             emp.`lastName`
),
rang AS (
SELECT e.annee AS annee, e.mois AS mois, e.nom AS nom, RANK() OVER(PARTITION BY e.annee, e.mois ORDER BY (- e.somme_amount)) AS Rang
FROM extr e
)
SELECT e1.annee, e1.mois, e1.nom AS 'Vendeur', e1.somme_amount AS 'Chiffre d\'affaire', r.Rang
FROM extr e1
INNER JOIN rang r ON e1.annee = r.annee AND e1.mois = r.mois AND e1.nom = r.nom
WHERE r.Rang =1 OR r.Rang = 2
ORDER BY e1.annee DESC, e1.mois DESC, r.Rang ASC
;
