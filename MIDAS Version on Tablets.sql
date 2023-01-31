SELECT	EquipmentLocation, Tablet, MAX(MIDAS_Version) AS MIDAS_Version, COUNT(*) AS Transactions
FROM	REPAIRS
WHERE	ReceivedOn > '07/15/2015' 
		AND Tablet NOT IN ('SDEV1','5YJQ1','YLSR1')
		AND InvoiceNumber IS NOT Null
GROUP BY EquipmentLocation, Tablet
ORDER BY EquipmentLocation, Tablet