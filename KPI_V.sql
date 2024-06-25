-- Active: 1710172595360@@51.178.25.157@23456@toys_and_models

USE toys_and_models;


/*--------------------*/
/* ANALYSE DES VENTES */
/*--------------------*/

/*Vente total de produit en nombre sur toute la bdd */
SELECT sum(od.`quantityOrdered`) AS 'Quantité vendue'
FROM orderdetails od
JOIN orders o USING(`orderNumber`)
WHERE o.`status` <> 'Cancelled';

/*Vente total de produit en nombre par an*/
SELECT YEAR(o.orderDate) AS 'Année', sum(od.`quantityOrdered`) AS 'Quantité vendu'
FROM orderdetails od
JOIN orders o USING(`orderNumber`)
WHERE o.`status` <> 'Cancelled'
GROUP BY YEAR(o.orderDate)
ORDER BY YEAR(o.orderDate) DESC;

/*Vente total de produit en nombre par mois/annnée*/
SELECT MONTH(o.orderDate) AS 'Mois', YEAR(o.orderDate) AS 'Année', sum(od.`quantityOrdered`) AS 'Quantité vendu'
FROM orderdetails od
JOIN orders o USING(`orderNumber`)
WHERE o.`status` <> 'Cancelled'
GROUP BY YEAR(o.orderDate), MONTH(o.orderDate)
ORDER BY YEAR(o.orderDate) DESC, MONTH(o.orderDate) DESC;

/* Comparaiason des ventes par rapport aux mois de l'année n-1 + taux d'évolution*/
WITH extract_annee AS (
    SELECT 
        MONTH(o.`orderDate`) AS mois,
        YEAR(o.`orderDate`) AS annee,
        sum(od.`quantityOrdered`) AS qte
    FROM orders o
    JOIN orderdetails od USING(`orderNumber`)
    WHERE o.`status` <> 'Cancelled'
    GROUP BY YEAR(o.`orderDate`), MONTH(o.`orderDate`)
)
SELECT  e1.mois AS 'Mois', 
        e2.annee AS 'Année n-1',
        e2.qte AS 'Quantité année n-1',
        e1.annee AS 'Année n',
        e1.qte AS 'Quantité année n',
        e1.qte - e2.qte AS 'Comparaison des ventes par rapport à l\'année n-1',
        (e1.qte - e2.qte) / e2.qte AS 'Taux d\'évolution'
FROM extract_annee e1
INNER JOIN extract_annee e2 ON e1.annee =  e2.annee+1 AND e1.mois =  e2.mois 
ORDER BY e1.annee DESC, e1.mois DESC;


/*---------------------------------*/
/* ANALYSE DES VENTES PAR CATEGORIE*/
/*---------------------------------*/

/*Vente total de produit par catégorie*/
SELECT p.`productLine` AS 'Catégorie', sum(od.`quantityOrdered`) AS 'Quantité vendu'
FROM orderdetails od
JOIN orders o USING(`orderNumber`)
JOIN products p USING(`productCode`)
WHERE o.`status` <> 'Cancelled'
GROUP BY p.`productLine`
ORDER BY p.`productLine`;

/*Vente total de produit par catégorie et par an*/
SELECT p.`productLine` AS 'Catégorie', YEAR(o.orderDate) AS 'Année', sum(od.`quantityOrdered`) AS 'Quantité vendu'
FROM orderdetails od
JOIN orders o USING(`orderNumber`)
JOIN products p USING(`productCode`)
WHERE o.`status` <> 'Cancelled'
GROUP BY p.`productLine`, YEAR(o.orderDate)
ORDER BY p.`productLine`, YEAR(o.orderDate) DESC;

/*Vente total de produit par catégorie et par mois/année*/
SELECT p.`productLine` AS 'Catégorie', MONTH(o.orderDate) AS 'Mois', YEAR(o.orderDate) AS 'Année', sum(od.`quantityOrdered`) AS 'Quantité vendu'
FROM orderdetails od
JOIN orders o USING(`orderNumber`)
JOIN products p USING(`productCode`)
WHERE o.`status` <> 'Cancelled'
GROUP BY p.`productLine`, YEAR(o.orderDate), MONTH(o.orderDate)
ORDER BY p.`productLine`, YEAR(o.orderDate) DESC, MONTH(o.orderDate) DESC;

/* Comparaison des ventes par rapport aux mois de l'année n-1 en fonction des catégories + taux d'évolution*/
WITH extract_annee AS (
    SELECT 
        MONTH(o.`orderDate`) AS mois,
        YEAR(o.`orderDate`) AS annee,
        p.`productLine` AS category,
        sum(od.`quantityOrdered`) AS qte
    FROM orders o
    JOIN orderdetails od USING(`orderNumber`)
    JOIN products p USING(`productCode`)
    WHERE o.`status` <> 'Cancelled'
    GROUP BY  p.`productLine`, YEAR(o.`orderDate`), MONTH(o.`orderDate`)
)
SELECT  e1.category AS 'Product Line',
        e1.mois AS 'Mois', 
        e1.annee AS 'Année n',
        e1.qte AS 'Quantité année n',
        e2.annee AS 'Année n-1',
        e2.qte AS 'Quantité année n-1',
        e1.qte - e2.qte AS 'Comparaison des ventes par rapport à l\'année n-1',
        (e1.qte - e2.qte) / e2.qte AS 'Taux d\'évolution'
FROM extract_annee e1
INNER JOIN extract_annee e2 ON e1.category = e2.category AND e1.annee =  e2.annee+1 AND e1.mois =  e2.mois 
ORDER BY e1.category, e1.annee DESC, e1.mois DESC;


/*--------------------------------*/
/* ANALYSE DES VENTES PAR ARTICLE */
/*--------------------------------*/

/* Nombre d'article par Commande*/
SELECT o.`orderNumber` AS 'numéro de commande', count(od.`productCode`) AS 'Quantité vendu'
FROM orderdetails od
JOIN orders o USING(`orderNumber`)
JOIN products p USING(`productCode`)
GROUP BY o.`orderNumber`
ORDER BY count(od.`productCode`) DESC;

/* Nombre d'article par Commande non annulé*/
SELECT o.`orderNumber` AS 'numéro de commande', count(od.`productCode`) AS 'Quantité vendu'
FROM orderdetails od
JOIN orders o USING(`orderNumber`)
JOIN products p USING(`productCode`)
WHERE o.`status` <> 'Cancelled'
GROUP BY o.`orderNumber`
ORDER BY count(od.`productCode`) DESC;


/*---------------------------------------*/
/* ANALYSE DES VENTES PAR PAYS et VILLES */
/*---------------------------------------*/

/* Nombre de vente par pays (non annulé)*/
SELECT  c.country AS 'Pays', count(od.`productCode`) AS 'Quantité vendu'
FROM orderdetails od
JOIN orders o USING(`orderNumber`)
JOIN customers c USING(`customerNumber`)
WHERE o.`status` <> 'Cancelled'
GROUP BY c.country
ORDER BY count(od.`productCode`) DESC;

/* nombre de vente par ville*/
SELECT  c.city AS 'Ville', count(od.`productCode`) AS 'Quantité vendu'
FROM orderdetails od
JOIN orders o USING(`orderNumber`)
JOIN customers c USING(`customerNumber`)
WHERE o.`status` <> 'Cancelled'
GROUP BY c.city
ORDER BY count(od.`productCode`) DESC;

/* nombre de vente par Pays/ville*/
SELECT c.country AS 'Pays',  c.city AS 'Ville', count(od.`productCode`) AS 'Quantité vendu'
FROM orderdetails od
JOIN orders o USING(`orderNumber`)
JOIN customers c USING(`customerNumber`)
WHERE o.`status` <> 'Cancelled'
GROUP BY c.country, c.city
ORDER BY  c.country, count(od.`productCode`) DESC;


/*---------------------------------------------------------------*/
/* ANALYSE DE LA FREQUENCE DES PRODUITS PAR CLIENT*/
/*---------------------------------------------------------------*/

/* Frequence Client par nom de produit*/
SELECT c.`customerName` AS 'Nom du client',p.`productName` AS 'Nom du produit',  count(p.`productName`) AS 'Quantité vendu'
FROM orderdetails od
JOIN orders o USING(`orderNumber`)
JOIN products p USING(`productCode`)
JOIN customers c USING(`customerNumber`)
WHERE o.`status` <> 'Cancelled'
GROUP BY p.`productName`, c.`customerName`
ORDER BY c.`customerName`,count(p.`productName`) DESC;

/*Frequence client par ligne produit*/
SELECT c.`customerName` AS 'Nom du client',p.`productLine` AS 'Ligne de produit',  count(p.`productName`) AS 'Quantité vendu'
FROM orderdetails od
JOIN orders o USING(`orderNumber`)
JOIN products p USING(`productCode`)
JOIN customers c USING(`customerNumber`)
WHERE o.`status` <> 'Cancelled'
GROUP BY p.`productLine`, c.`customerName`
ORDER BY c.`customerName`,count(p.`productLine`) DESC;

/*Frequence Ligne produit par client*/
SELECT p.`productLine` AS 'Ligne de produit', c.`customerName` AS 'Nom du client', count(p.`productName`) AS 'Quantité vendu'
FROM orderdetails od
JOIN orders o USING(`orderNumber`)
JOIN products p USING(`productCode`)
JOIN customers c USING(`customerNumber`)
WHERE o.`status` <> 'Cancelled'
GROUP BY p.`productLine`, c.`customerName`
ORDER BY p.`productLine`,count(p.`productLine`) DESC;

/* Frequence nom de produit par client*/
SELECT p.`productName` AS 'Nom du produit', c.`customerName` AS 'Nom du client', count(p.`productName`) AS 'Quantité vendu'
FROM orderdetails od
JOIN orders o USING(`orderNumber`)
JOIN products p USING(`productCode`)
JOIN customers c USING(`customerNumber`)
WHERE o.`status` <> 'Cancelled'
GROUP BY p.`productName`, c.`customerName`
ORDER BY p.`productName`,count(p.`productName`) DESC;