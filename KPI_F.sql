-- Active: 1710172595360@@51.178.25.157@23456@toys_and_models
USE toys_and_models;


/*----------------------------------*/
/* ANALYSE DES CHIFFRES D'AFFAIRES  */
/*----------------------------------*/

/*REQUETE pour CA des commandes des deux derniers mois par pays*/
WITH extract_annee AS (
    SELECT 
        YEAR(p.`paymentDate`) AS annee_mois,
        MONTH(p.`paymentDate`) AS mois,
        c.`country` AS pays,
        sum(p.amount) AS somme_amount
    FROM customers c
    LEFT JOIN payments p USING(`customerNumber`)
    LEFT JOIN orders o USING(`customerNumber`)
    WHERE p.`paymentDate` IS NOT NULL AND o.`status` <> 'Cancelled'
    GROUP BY  YEAR(p.`paymentDate`) , MONTH(p.`paymentDate`), c.`country`
    ORDER BY YEAR(p.`paymentDate`) DESC, MONTH(p.`paymentDate`) DESC, c.`country`ASC
),
extract_2_mois AS (
    SELECT 
        YEAR(p.`paymentDate`) AS annee_mois,
        MONTH(p.`paymentDate`) AS mois
    FROM customers c
    LEFT JOIN payments p USING(`customerNumber`)
    LEFT JOIN orders o USING(`customerNumber`)
    WHERE p.`paymentDate` IS NOT NULL AND o.`status` <> 'Cancelled'
    GROUP BY YEAR(p.`paymentDate`) , MONTH(p.`paymentDate`)
    ORDER BY YEAR(p.`paymentDate`) DESC, MONTH(p.`paymentDate`) DESC
    LIMIT 2
)
SELECT e.annee_mois AS 'Année', e.mois AS 'Mois', e.pays, e.somme_amount AS 'Chiffre d\'affaire'
FROM extract_annee e
INNER JOIN extract_2_mois e2m USING(mois, annee_mois);

/* CA en fonction des lignes de produit par an*/
SELECT  pr.`productLine`, YEAR(o.`orderDate`) AS 'Année',  sum(pa.amount) AS 'Chiffre d\'affaire'
FROM payments pa
 JOIN customers c USING(`customerNumber`)
 JOIN orders o USING(`customerNumber`)
 JOIN orderdetails od USING(`orderNumber`)
 JOIN products pr USING(`productCode`)
WHERE pa.`paymentDate` IS NOT NULL AND o.`status` <> 'Cancelled'
GROUP BY pr.`productLine`, YEAR(o.`orderDate`)
ORDER BY  pr.`productLine` DESC, YEAR(o.`orderDate`) DESC;

/* Top 80 % du CA en fonction des produits par an*/







/*--------------------------------------------------------*/
/* ANALYSE DES COMMANDES NON PAYEES ET RETARD DE PAIEMENT */
/*--------------------------------------------------------*/

/* REQUETE pour  connaitre les commandes non payés --> status ON HOLD ??? pour en attente de paiement */ 
SELECT c.`customerName`, o.`orderDate`, p.`paymentDate`, p.`amount`, o.`status`, c.`creditLimit`, o.`comments`
FROM customers c
LEFT JOIN payments p USING(`customerNumber`)
LEFT JOIN orders o USING(`customerNumber`)
WHERE o.status = 'On Hold'
ORDER BY o.`status` ASC;

/*Combien de commande en attente de paiement si pas ON HOLD en status à prendre en compte*/
SELECT count(o.`orderDate`) - count(p.`paymentDate`) AS 'commande faite  sans date de paiement'
FROM customers c
LEFT JOIN payments p USING(`customerNumber`)
LEFT JOIN orders o USING(`customerNumber`);

/* Combien de commande sont en retard de paiement */



/*----------------------------------------*/
/* ANALYSE DES BENEFICES ET PROFITABILITE */
/*----------------------------------------*/

/* Bénéfice par an */
WITH extract AS(
    SELECT  YEAR(`orderDate`) AS annee, 
            od.`quantityOrdered` AS qte_vendu, 
            od.`priceEach` AS prix_unitaire, 
            p.`buyPrice` AS prix_achat_unitaire, 
            od.`priceEach` - p.`buyPrice` AS benefice_unitaire,
            od.`quantityOrdered` * (od.`priceEach` - p.`buyPrice`) AS benefice_commande
    FROM orders o
    INNER JOIN orderdetails od USING(`orderNumber`)
    INNER JOIN products p USING(`productCode`)
)
SELECT e.annee, sum(benefice_commande) 
FROM extract e
GROUP BY e.annee 
ORDER BY e.annee DESC;

/* Bénéfice par annnée/mois */
WITH extract AS(
    SELECT  YEAR(`orderDate`) AS annee, 
            MONTH(`orderDate`) AS mois, 
            od.`quantityOrdered` AS qte_vendu, 
            od.`priceEach` AS prix_unitaire, 
            p.`buyPrice` AS prix_achat_unitaire, 
            od.`priceEach` - p.`buyPrice` AS benefice_unitaire,
            od.`quantityOrdered` * (od.`priceEach` - p.`buyPrice`) AS benefice_commande
    FROM orders o
    INNER JOIN orderdetails od USING(`orderNumber`)
    INNER JOIN products p USING(`productCode`)
)
SELECT e.annee, e.mois, sum(benefice_commande) AS Benefice
FROM extract e
GROUP BY e.annee, e.mois
ORDER BY e.annee DESC, e.mois DESC;

/* Bénéfice par mois et évolution pour l'année n-1 */
WITH extract AS(
    SELECT  YEAR(`orderDate`) AS annee, 
            MONTH(`orderDate`) AS mois, 
            od.`quantityOrdered` AS qte_vendu, 
            od.`priceEach` AS prix_unitaire, 
            p.`buyPrice` AS prix_achat_unitaire, 
            od.`priceEach` - p.`buyPrice` AS benefice_unitaire,
            od.`quantityOrdered` * (od.`priceEach` - p.`buyPrice`) AS benefice_commande
    FROM orders o
    INNER JOIN orderdetails od USING(`orderNumber`)
    INNER JOIN products p USING(`productCode`)
),
somme_benefice_group_mois_annee AS (
SELECT e.annee, e.mois, sum(benefice_commande) AS benefice
FROM extract e
GROUP BY e.annee, e.mois
)
SELECT sb1.annee, sb1.mois, sb1.benefice, sb2.annee, sb2.benefice
FROM somme_benefice_group_mois_annee sb1
INNER JOIN somme_benefice_group_mois_annee sb2 ON sb1.annee = sb2.annee +1 AND sb1.mois = sb2.mois
ORDER BY sb1.annee DESC, sb1.mois DESC
;

/* Produit - Top 80 % du bénéfice par année*/


/* Top 80 % du CA en fonction des produits par année/mois */


/* Bénéfice par ligne produit */ 
WITH extract AS(
    SELECT  YEAR(`orderDate`) AS annee, 
            p.`productLine` AS productLine,
            od.`quantityOrdered` AS qte_vendu, 
            od.`priceEach` AS prix_unitaire, 
            p.`buyPrice` AS prix_achat_unitaire, 
            od.`priceEach` - p.`buyPrice` AS benefice_unitaire,
            od.`quantityOrdered` * (od.`priceEach` - p.`buyPrice`) AS benefice_commande
    FROM orders o
    INNER JOIN orderdetails od USING(`orderNumber`)
    INNER JOIN products p USING(`productCode`)
)
SELECT e.productLine, e.annee, sum(benefice_commande) 
FROM extract e
GROUP BY e.productLine, e.annee 
ORDER BY e.productLine, e.annee DESC;

/* Bénéfice par produit */
WITH extract AS(
    SELECT  YEAR(`orderDate`) AS annee, 
            p.`productName` AS productName,
            od.`quantityOrdered` AS qte_vendu, 
            od.`priceEach` AS prix_unitaire, 
            p.`buyPrice` AS prix_achat_unitaire, 
            od.`priceEach` - p.`buyPrice` AS benefice_unitaire,
            od.`quantityOrdered` * (od.`priceEach` - p.`buyPrice`) AS benefice_commande
    FROM orders o
    INNER JOIN orderdetails od USING(`orderNumber`)
    INNER JOIN products p USING(`productCode`)
)
SELECT e.productName, e.annee, sum(benefice_commande) 
FROM extract e
GROUP BY e.productName, e.annee 
ORDER BY e.productName, e.annee DESC;

/* Bénéfice par ligne produit et taux d'évolution */ 
WITH extract AS(
    SELECT  YEAR(`orderDate`) AS annee, 
            p.`productLine` AS productLine,
            od.`quantityOrdered` AS qte_vendu, 
            od.`priceEach` AS prix_unitaire, 
            p.`buyPrice` AS prix_achat_unitaire, 
            od.`priceEach` - p.`buyPrice` AS benefice_unitaire,
            od.`quantityOrdered` * (od.`priceEach` - p.`buyPrice`) AS benefice_commande
    FROM orders o
    INNER JOIN orderdetails od USING(`orderNumber`)
    INNER JOIN products p USING(`productCode`)
),
somme_benefice AS (
    SELECT e.productLine, e.annee, sum(benefice_commande) AS benefice
    FROM extract e
    GROUP BY e.productLine, e.annee
)
SELECT e1.productLine, e1.annee AS 'Année N', e1.benefice AS 'Benefice année N', e2.annee AS 'Année N-1', e2.benefice AS 'Benefice année N-1', (e1.benefice-e2.benefice)/e2.benefice
FROM somme_benefice e1
INNER JOIN somme_benefice e2 ON e1.annee = e2.annee + 1 AND e1.productLine = e2.productLine
ORDER BY e1.productLine, e1.annee DESC;



/* Produit ayant le plus de marge */
















