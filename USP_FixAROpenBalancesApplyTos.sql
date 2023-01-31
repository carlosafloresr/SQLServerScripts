/*
EXECUTE USP_FixAROpenBalancesApplyTos 'IMC'
*/
ALTER PROCEDURE USP_FixAROpenBalancesApplyTos
		@Company	Varchar(5)
AS
DECLARE	@Query		Varchar(3000)

SET @Query = N'DELETE ' + RTRIM(@Company) + '.dbo.RM20201
FROM	(
		SELECT	R1.*,
				R2.ApFrDcNm
		FROM	(
				SELECT	R1.CustNmbr, 
						R1.DocNumbr,
						(ORTRXAMT - (Select ISNULL(SUM(AppToAmt), 0.0) FROM ' + RTRIM(@Company) + '.dbo.RM30201 R2 WHERE R2.CustNmbr = R1.CustNmbr And R2.ApToDcNm = R1.DocNumbr) - (Select ISNULL(SUM(AppToAmt), 0.0) As Balance FROM ' + RTRIM(@Company) + '.dbo.RM20201 R3 WHERE R3.CustNmbr = R1.CustNmbr And R3.ApToDcNm = R1.DocNumbr)) As Balance,
						ORTRXAMT,
						CurTrxAm,
						Applied_H = (Select ISNULL(SUM(AppToAmt), 0.0) FROM ' + RTRIM(@Company) + '.dbo.RM30201 R2 WHERE R2.CustNmbr = R1.CustNmbr And R2.ApToDcNm = R1.DocNumbr),
						Applied_O = (Select ISNULL(SUM(AppToAmt), 0.0) FROM ' + RTRIM(@Company) + '.dbo.RM20201 R3 WHERE R3.CustNmbr = R1.CustNmbr And R3.ApToDcNm = R1.DocNumbr)
				FROM	RM20101 R1
				) R1
				INNER JOIN ' + RTRIM(@Company) + '.dbo.RM20201 R2 ON R1.CustNmbr = R2.CustNmbr AND R1.DocNumbr = R2.ApToDcNm
				INNER JOIN ' + RTRIM(@Company) + '.dbo.RM30201 R3 ON R1.CustNmbr = R3.CustNmbr AND R1.DocNumbr = R3.ApToDcNm AND R2.ApFrDcNm = R3.ApFrDcNm
		WHERE	(Applied_H = Applied_O
				OR CurTrxAm - (Applied_H - Applied_O) <> CurTrxAm)
				AND Applied_H <> 0
		) DATA
WHERE	RM20201.CustNmbr = DATA.CustNmbr
		AND RM20201.ApToDcNm = DATA.DocNumbr
		AND RM20201.ApFrDcNm = DATA.ApFrDcNm'

EXECUTE(@Query)