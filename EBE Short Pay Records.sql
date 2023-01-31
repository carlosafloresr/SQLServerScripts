SELECT *
FROM   (
        SELECT  R1.CUSTNMBR, 
                R1.DOCNUMBR AS [Pro], 
                R1.DOCDATE, 
                R1.ORTRXAMT, 
                R1.CURTRXAM, 
                R1.RMDTYPAL, 
				CM.CUSTCLAS,
                ApplyDate = (SELECT MAX(R2.GLPOSTDT) FROM LENSASQL001." & szGPDBName & ".dbo.RM20201 R2 WHERE R1.CUSTNMBR = R2.CUSTNMBR AND R1.DOCNUMBR = R2.APTODCNM AND R2.APFRDCTY <> 7)
        FROM	LENSASQL001." & szGPDBName & ".dbo.RM20101 R1
                INNER JOIN GPCustom.dbo.CustomerMaster CM ON R1.CUSTNMBR = CM.CUSTNMBR and CM.CompanyId = '" & szGPDBName & "'
        WHERE	R1.CURTRXAM > 0 
                AND R1.ORTRXAMT > R1.CURTRXAM 
                AND R1.VOIDSTTS = 0 
                AND R1.RMDTYPAL < 7
				AND CM.ExcludeFromShortPay = 0
				AND CM.CUSTCLAS <> 'DEP'
				AND GPCustom.dbo.AT('-', R1.DOCNUMBR, 2) = 0
        ) DATA
WHERE  ApplyDate >= (SELECT VarD FROM LENSASQL001.GPCustom.dbo.Parameters WHERE ParameterCode = 'EBE_SHORTPAY_STARTDATE' AND Company = '" & szGPDBName & "')
