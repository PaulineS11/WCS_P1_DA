-- Active: 1710172595360@@51.178.25.157@23456@toys_and_models

USE toys_and_models;


/*--------------------------------------------------------*/
/*               ANALYSE DES STOCKS                       */
/*--------------------------------------------------------*/

/* Stock des 5 produits les plus commandés sur le total*/
WITH somme_qte_par_nom_produit AS (
    SELECT p.`productName` AS produit, sum(od.`quantityOrdered`) AS somme
    FROM orderdetails od
    JOIN orders o USING(`orderNumber`)
    JOIN products p USING(`productCode`)
    WHERE o.`status` <> 'Cancelled'
    GROUP BY p.`productName`
)
SELECT produit, sqnp.somme AS 'Quantité vendu', DENSE_RANK() OVER(ORDER BY sqnp.somme DESC) AS 'Rang'
FROM somme_qte_par_nom_produit sqnp
LIMIT 5;

/* Stock des 5 produits les plus commandés pour année en cours*/
WITH somme_qte_par_nom_produit AS (
    SELECT p.`productName` AS produit, sum(od.`quantityOrdered`) AS somme
    FROM orderdetails od
    JOIN orders o USING(`orderNumber`)
    JOIN products p USING(`productCode`)
    WHERE o.`status` <> 'Cancelled' AND YEAR(o.`orderDate`) = YEAR(CURDATE())
    GROUP BY p.`productName`
)
SELECT sqnp.produit, sqnp.somme AS 'Quantité vendu', DENSE_RANK() OVER(ORDER BY sqnp.somme DESC) AS 'Rang'
FROM somme_qte_par_nom_produit sqnp
LIMIT 5;


