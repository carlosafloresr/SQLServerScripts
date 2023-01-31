--select * from sysobjects

--SELECT Name 
--    FROM sys.procedures 
--    WHERE OBJECT_DEFINITION(object_id) LIKE '%USP_%' 
 
--SELECT OBJECT_NAME(object_id) 
--    FROM sys.sql_modules 
--    WHERE Definition LIKE '%USP_%' 
--    AND OBJECTPROPERTY(object_id, 'IsProcedure') = 1 
 
SELECT	* 
FROM	INFORMATION_SCHEMA.ROUTINES 
WHERE	ROUTINE_DEFINITION LIKE '%Custom_GetSummaryAging_PostSync%' 
		AND ROUTINE_TYPE = 'PROCEDURE'
    --AND PATINDEX('%EscrowTransaction%', Routine_Definition) > 0
    --AND Specific_Name NOT IN (SELECT Specific_Name 
				--				FROM INFORMATION_SCHEMA.ROUTINES 
				--				WHERE ROUTINE_DEFINITION LIKE '%USP_%' 
				--				--AND ROUTINE_TYPE = 'PROCEDURE'
				--				--AND PATINDEX('%View_EscrowTransaction%', Routine_Definition) > 0
				--			)