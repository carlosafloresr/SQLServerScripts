ALTER VIEW View_Payroll_Overtime
AS
SELECT EmployId, chekdate, PayrolCD, UprTrxAm, 'AIS' AS DBName FROM AIS..UPR30300 WHERE PayrolCD IN ('OT-1', 'OT-2', 'NEOT')
UNION
SELECT EmployId, chekdate, PayrolCD, UprTrxAm, 'FI' AS DBName FROM FI..UPR30300 WHERE PayrolCD IN ('OT-1', 'OT-2', 'NEOT')
UNION
SELECT EmployId, chekdate, PayrolCD, UprTrxAm, 'FRTES' AS DBName FROM FRTES..UPR30300 WHERE PayrolCD IN ('OT-1', 'OT-2', 'NEOT')
UNION
SELECT EmployId, chekdate, PayrolCD, UprTrxAm, 'IMC' AS DBName FROM IMC..UPR30300 WHERE PayrolCD IN ('OT-1', 'OT-2', 'NEOT')
UNION
SELECT EmployId, chekdate, PayrolCD, UprTrxAm, 'RCCL' AS DBName FROM RCCL..UPR30300 WHERE PayrolCD IN ('OT-1', 'OT-2', 'NEOT')
UNION
SELECT EmployId, chekdate, PayrolCD, UprTrxAm, 'RCMR' AS DBName FROM RCMR..UPR30300 WHERE PayrolCD IN ('OT-1', 'OT-2', 'NEOT')
UNION
SELECT 0 AS EmployId, Null AS chekdate, '' AS PayrolCD, 0 AS UprTrxAm, 'ALL' AS DBName

SELECT * FROM  View_Payroll_Overtime WHERE EmployId = 10 AND chekdate BETWEEN '1/19/2006' AND '1/19/2006' AND DBNAME = 'RCMR'