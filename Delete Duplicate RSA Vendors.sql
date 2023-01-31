--sp_RSA_VendorsNetwork_GetById 806, 'gis'
/*
DELETE RSA_VendorsNetworkGP WHERE Fk_RSA_VendorsNetworkId IN (67, 131, 662)
DELETE RSA_VendorsNetwork WHERE RSA_VendorsNetworkId IN (67, 131, 662)
UPDATE Tickets SET IdVendorInfo = 663 WHERE IdVendorInfo IN (67, 131, 662)
*/
SELECT	*
FROM	RSA_VendorsNetwork
--WHERE	Vendor LIKE '%All Truck%'
ORDER BY 2, 3, 4, 5

SELECT	*
FROM	Tickets
WHERE	IdVendorInfo IN (155,
210,
237,
245,
415,
434,
457)