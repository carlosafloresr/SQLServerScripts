SELECT	*, 
		COUNT(curReporte.SecretarioID) AS Agremiados, 
		COUNT(curReporte.AmbulantesID) AS Actividad, 
		COUNT(IIF(curReporte.AmbulantesID = 1,curReporte.AmbulantesID,0)) AS TA1, 
		COUNT(IIF(curReporte.AmbulantesID = 2,curReporte.AmbulantesID,0)) AS TA2, 
		COUNT(curReporte.ActividadesID) AS Giro 
FROM	curReporte 
Group by SecretarioID 
ORDER BY NombreCompleto
INTO CURSOR curReporte

SELECT	'1' AS Tipo,
		SecretarioID,
		AmbulantesID AS Codigo,
		COUNT(AmbulantesID) AS Contador
FROM	curReporte
GROUP BY SecretarioID
UNION
SELECT	'2' AS Tipo,
		SecretarioID,
		Actividad,
		COUNT(Actividad) AS Contador
FROM	curReporte
GROUP BY SecretarioID
UNION
SELECT	'3' AS Tipo,
		SecretarioID,
		Giro,
		COUNT(Giro) AS Contador
FROM	curReporte
GROUP BY SecretarioID
ORDER BY 1,2