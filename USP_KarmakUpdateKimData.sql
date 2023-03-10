/*
EXECUTE USP_KarmakUpdateKimData
*/
ALTER PROCEDURE [dbo].[USP_KarmakUpdateKimData]
AS
DECLARE	@InvoiceNumber	Int

EXECUTE	USP_QuerySWS 'SELECT t_code AS UnitNumber, div_code, CASE WHEN mytruck = ''Y'' THEN ''M'' ELSE type END AS Type FROM TRK.DRIVER WHERE Type <> ''C'' UNION SELECT Code AS UnitNumber, div_code, ''C'' AS Type FROM TRK.TRACTOR', '##curTrucks'

DECLARE KarmakInvoices CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	InvoiceNumber
FROM	KarmakIntegration
WHERE	Processed = 2
		AND CustomerNumber NOT IN ('AIS','GIS','RCMR')
		AND InvoiceTotal > 0
		AND Account1 IS NUll
ORDER BY InvoiceNumber

OPEN KarmakInvoices 
FETCH FROM KarmakInvoices INTO @InvoiceNumber

WHILE @@FETCH_STATUS = 0 
BEGIN
	UPDATE	KarmakIntegration
	SET		KarmakIntegration.TruckType			= RECS.TruckType,
			KarmakIntegration.IsClaim			= RECS.IsClaim,
			KarmakIntegration.NumberOfServices	= RECS.NumberOfServices,
			KarmakIntegration.ServiceTypes		= RECS.ServiceTypes,
			KarmakIntegration.UnitNumber		= RECS.UnitNumber,
			KarmakIntegration.Account1			= RECS.Account1,
			KarmakIntegration.Description1		= RECS.Description1,
			KarmakIntegration.Amount1			= RECS.Amount1,
			KarmakIntegration.Account2			= RECS.Account2,
			KarmakIntegration.Description2		= RECS.Description2,
			KarmakIntegration.Amount2			= RECS.Amount2,
			KarmakIntegration.Account3			= RECS.Account3,
			KarmakIntegration.Description3		= RECS.Description3,
			KarmakIntegration.Amount3			= RECS.Amount3,
			KarmakIntegration.Division			= RECS.Division,
			KarmakIntegration.Category			= RECS.Category,
			KarmakIntegration.Approved			= 1,
			KarmakIntegration.AcctApproved		= CASE WHEN RECS.Account1 IS NULL THEN 0 ELSE 1 END
	FROM	(
			SELECT	TKA.InvoiceNumber,
					KSO.IsClaim,
					KSO.NumberOfServices,
					KSO.ServiceTypes,
					TRK.UnitNumber,
					TRK.div_code AS Division,
					CASE WHEN KSO.NumberOfServices > 1 THEN 'Multi-' + RTRIM(KSO.ServiceTypes) ELSE
					CASE WHEN RTRIM(KSO.ServiceTypes) = 'M' THEN'M&R'
						 WHEN RTRIM(KSO.ServiceTypes) = 'T' THEN'Tires'
						 ELSE 'PeopleNet' END END AS Category,
					CASE WHEN TRK.Type = 'C' THEN 'COM' ELSE CASE WHEN TRK.Type = 'O' THEN 'OOP' ELSE 'MYT' END END AS TruckType,
					REPLACE(CASE WHEN KSO.IsClaim = 1 THEN
								CASE WHEN KSO.NumberOfServices = 1 THEN
									 CASE WHEN KSO.ServiceTypes = 'M' THEN REPLACE((SELECT KAC.AcctMaintRep FROM KarmakAccounts KAC WHERE LEFT(KAC.AccountType, 1) = TRK.Type), 'DD', ISNULL(TKA.Division, 'DD'))
									 ELSE REPLACE((SELECT KAC.AcctTires FROM KarmakAccounts KAC WHERE LEFT(KAC.AccountType, 1) = TRK.Type), 'DD', ISNULL(TKA.Division, 'DD')) END
								ELSE
									 CASE WHEN SUBSTRING(KSO.ServiceTypes, 1, 1) = 'M' THEN REPLACE((SELECT KAC.AcctMaintRep FROM KarmakAccounts KAC WHERE LEFT(KAC.AccountType, 1) = TRK.Type), 'DD', ISNULL(TKA.Division, 'DD'))
									 ELSE REPLACE((SELECT KAC.AcctTires FROM KarmakAccounts KAC WHERE LEFT(KAC.AccountType, 1) = TRK.Type), 'DD', ISNULL(TKA.Division, 'DD')) END
								END
							ELSE
								CASE WHEN KSO.NumberOfServices = 1 THEN
									 CASE WHEN KSO.ServiceTypes = 'M' THEN REPLACE((SELECT KAC.AcctMaintRep FROM KarmakAccounts KAC WHERE LEFT(KAC.AccountType, 1) = TRK.Type), 'DD', ISNULL(TKA.Division, 'DD'))
										  WHEN KSO.ServiceTypes = 'T' THEN REPLACE((SELECT KAC.AcctTires FROM KarmakAccounts KAC WHERE LEFT(KAC.AccountType, 1) = TRK.Type), 'DD', ISNULL(TKA.Division, 'DD'))
										  WHEN KSO.ServiceTypes = 'P' THEN REPLACE((SELECT KAC.AcctPeopleNet FROM KarmakAccounts KAC WHERE LEFT(KAC.AccountType, 1) = TRK.Type), 'DD', ISNULL(TKA.Division, 'DD'))
									 ELSE Null END
								ELSE
									 CASE WHEN SUBSTRING(KSO.ServiceTypes, 1, 1) = 'M' THEN REPLACE((SELECT KAC.AcctMaintRep FROM KarmakAccounts KAC WHERE LEFT(KAC.AccountType, 1) = TRK.Type), 'DD', ISNULL(TKA.Division, 'DD'))
										  WHEN SUBSTRING(KSO.ServiceTypes, 1, 1) = 'T' THEN REPLACE((SELECT KAC.AcctTires FROM KarmakAccounts KAC WHERE LEFT(KAC.AccountType, 1) = TRK.Type), 'DD', ISNULL(TKA.Division, 'DD'))
										  WHEN SUBSTRING(KSO.ServiceTypes, 1, 1) = 'P' THEN REPLACE((SELECT KAC.AcctPeopleNet FROM KarmakAccounts KAC WHERE LEFT(KAC.AccountType, 1) = TRK.Type), 'DD', ISNULL(TKA.Division, 'DD'))
									 ELSE Null END
								END
							END, 'DD', TRK.div_code) AS Account1
						,CASE WHEN TKA.Amount1 IS Null THEN
							CASE WHEN KSO.IsClaim = 1 THEN
								CASE WHEN KSO.NumberOfServices = 1 THEN
									 CASE WHEN KSO.ServiceTypes = 'M' THEN AmntMR - (AmntMR - TKA.InvoiceTotal) ELSE AmntTires - (AmntTires - KSO.InvoiceTotal) END
								ELSE
									 CASE WHEN SUBSTRING(KSO.ServiceTypes, 1, 1) = 'M' THEN AmntMR - (AmntMR - TKA.InvoiceTotal) ELSE AmntTires - (AmntTires - TKA.InvoiceTotal) END
								END
							ELSE
								CASE WHEN KSO.NumberOfServices = 1 THEN
									 CASE WHEN KSO.ServiceTypes = 'M' THEN AmntMR - (AmntMR - TKA.InvoiceTotal)
										  WHEN KSO.ServiceTypes = 'T' THEN AmntTires - (AmntTires - TKA.InvoiceTotal)
									 ELSE AmntPeopleNet - (AmntPeopleNet - TKA.InvoiceTotal) END
								ELSE
									 CASE WHEN SUBSTRING(KSO.ServiceTypes, 1, 1) = 'M' THEN AmntMR
										  WHEN SUBSTRING(KSO.ServiceTypes, 1, 1) = 'T' THEN AmntTires
									 ELSE AmntPeopleNet END
								END
							END
						ELSE TKA.Amount1 END AS Amount1
						,CASE WHEN TKA.Description1 IS Null THEN
							CASE WHEN KSO.IsClaim = 1 THEN
								CASE WHEN KSO.NumberOfServices = 1 THEN
									 CASE WHEN KSO.ServiceTypes = 'M' THEN DescMR ELSE DescTires END
								ELSE
									 CASE WHEN SUBSTRING(KSO.ServiceTypes, 1, 1) = 'M' THEN DescMR ELSE DescTires END
								END
							ELSE
								CASE WHEN KSO.NumberOfServices = 1 THEN
									 CASE WHEN KSO.ServiceTypes = 'M' THEN DescMR
										  WHEN KSO.ServiceTypes = 'T' THEN DescTires
									 ELSE DescPeopleNet END
								ELSE
									 CASE WHEN SUBSTRING(KSO.ServiceTypes, 1, 1) = 'M' THEN DescMR
										  WHEN SUBSTRING(KSO.ServiceTypes, 1, 1) = 'T' THEN DescTires
									 ELSE DescPeopleNet END
								END
							END
						ELSE TKA.Description1 END AS Description1
						,REPLACE(CASE WHEN TKA.Account2 IS Null THEN
							CASE WHEN KSO.IsClaim = 1 THEN
								CASE WHEN KSO.NumberOfServices = 2 THEN
									 CASE WHEN SUBSTRING(KSO.ServiceTypes, 2, 1) = 'M' THEN REPLACE((SELECT KAC.AcctMaintRep FROM KarmakAccounts KAC WHERE LEFT(KAC.AccountType, 1) = TRK.Type), 'DD', ISNULL(TKA.Division, 'DD'))
									 ELSE REPLACE((SELECT KAC.AcctTires FROM KarmakAccounts KAC WHERE LEFT(KAC.AccountType, 1) = TRK.Type), 'DD', ISNULL(TKA.Division, 'DD')) END
								ELSE Null END
							ELSE
								CASE WHEN KSO.NumberOfServices = 2 THEN
									 CASE WHEN SUBSTRING(KSO.ServiceTypes, 2, 1) = 'M' THEN REPLACE((SELECT KAC.AcctMaintRep FROM KarmakAccounts KAC WHERE LEFT(KAC.AccountType, 1) = TRK.Type), 'DD', ISNULL(TKA.Division, 'DD'))
										  WHEN SUBSTRING(KSO.ServiceTypes, 2, 1) = 'T' THEN REPLACE((SELECT KAC.AcctTires FROM KarmakAccounts KAC WHERE LEFT(KAC.AccountType, 1) = TRK.Type), 'DD', ISNULL(TKA.Division, 'DD'))
										  WHEN SUBSTRING(KSO.ServiceTypes, 2, 1) = 'P' THEN REPLACE((SELECT KAC.AcctPeopleNet FROM KarmakAccounts KAC WHERE LEFT(KAC.AccountType, 1) = TRK.Type), 'DD', ISNULL(TKA.Division, 'DD'))
									 ELSE Null END
								ELSE
									CASE WHEN SUBSTRING(KSO.ServiceTypes, 3, 1) = 'M' THEN REPLACE((SELECT KAC.AcctMaintRep FROM KarmakAccounts KAC WHERE LEFT(KAC.AccountType, 1) = TRK.Type), 'DD', ISNULL(TKA.Division, 'DD'))
										 WHEN SUBSTRING(KSO.ServiceTypes, 3, 1) = 'T' THEN REPLACE((SELECT KAC.AcctTires FROM KarmakAccounts KAC WHERE LEFT(KAC.AccountType, 1) = TRK.Type), 'DD', ISNULL(TKA.Division, 'DD'))
										 WHEN SUBSTRING(KSO.ServiceTypes, 3, 1) = 'P' THEN REPLACE((SELECT KAC.AcctPeopleNet FROM KarmakAccounts KAC WHERE LEFT(KAC.AccountType, 1) = TRK.Type), 'DD', ISNULL(TKA.Division, 'DD'))
									ELSE Null END
								END
							END
						ELSE TKA.Account2 END, 'DD', TRK.div_code) AS Account2
						,CASE WHEN TKA.Amount2 IS Null THEN
							CASE WHEN KSO.IsClaim = 1 THEN
								CASE WHEN KSO.NumberOfServices = 2 THEN
									 CASE WHEN SUBSTRING(KSO.ServiceTypes, 2, 1) = 'M' THEN AmntMR - (AmntMR - TKA.InvoiceTotal) ELSE AmntTires - (AmntTires - TKA.InvoiceTotal) END
								ELSE Null END
							ELSE
								CASE WHEN KSO.NumberOfServices = 2 THEN
									 CASE WHEN SUBSTRING(KSO.ServiceTypes, 2, 1) = 'M' THEN AmntMR - (AmntMR - TKA.InvoiceTotal)
										  WHEN SUBSTRING(KSO.ServiceTypes, 2, 1) = 'T' THEN AmntTires - (AmntTires - TKA.InvoiceTotal)
										  WHEN SUBSTRING(KSO.ServiceTypes, 2, 1) = 'P' THEN AmntPeopleNet - (AmntPeopleNet - TKA.InvoiceTotal)
									 ELSE Null END
								ELSE Null END
							END
						ELSE TKA.Amount2 END AS Amount2
						,CASE WHEN TKA.Description2 IS Null THEN
							CASE WHEN KSO.IsClaim = 1 THEN
								CASE WHEN KSO.NumberOfServices = 2 THEN
									 CASE WHEN SUBSTRING(KSO.ServiceTypes, 2, 1) = 'M' THEN DescMR ELSE DescTires END
								ELSE Null END
							ELSE
								CASE WHEN KSO.NumberOfServices = 2 THEN
									 CASE WHEN SUBSTRING(KSO.ServiceTypes, 2, 1) = 'M' THEN DescMR
										  WHEN SUBSTRING(KSO.ServiceTypes, 2, 1) = 'T' THEN DescTires
										  WHEN SUBSTRING(KSO.ServiceTypes, 2, 1) = 'P' THEN DescPeopleNet
									 ELSE Null END
								ELSE Null END
							END
						ELSE TKA.Description2 END AS Description2
						,REPLACE(CASE WHEN TKA.Account3 IS Null THEN
							CASE WHEN KSO.IsClaim = 1 THEN
								CASE WHEN KSO.NumberOfServices = 3 THEN
									 CASE WHEN SUBSTRING(KSO.ServiceTypes, 2, 1) = 'M' THEN REPLACE((SELECT KAC.AcctMaintRep FROM KarmakAccounts KAC WHERE LEFT(KAC.AccountType, 1) = TRK.Type), 'DD', ISNULL(TKA.Division, 'DD'))
									 ELSE REPLACE((SELECT KAC.AcctTires FROM KarmakAccounts KAC WHERE LEFT(KAC.AccountType, 1) = TRK.Type), 'DD', ISNULL(TKA.Division, 'DD')) END
								ELSE Null END
							ELSE
								CASE WHEN KSO.NumberOfServices = 3 THEN
									 CASE WHEN SUBSTRING(KSO.ServiceTypes, 3, 1) = 'M' THEN REPLACE((SELECT KAC.AcctMaintRep FROM KarmakAccounts KAC WHERE LEFT(KAC.AccountType, 1) = TRK.Type), 'DD', ISNULL(TKA.Division, 'DD'))
										  WHEN SUBSTRING(KSO.ServiceTypes, 3, 1) = 'T' THEN REPLACE((SELECT KAC.AcctTires FROM KarmakAccounts KAC WHERE LEFT(KAC.AccountType, 1) = TRK.Type), 'DD', ISNULL(TKA.Division, 'DD'))
										  WHEN SUBSTRING(KSO.ServiceTypes, 3, 1) = 'P' THEN REPLACE((SELECT KAC.AcctPeopleNet FROM KarmakAccounts KAC WHERE LEFT(KAC.AccountType, 1) = TRK.Type), 'DD', ISNULL(TKA.Division, 'DD'))
									 ELSE Null END
								ELSE Null END
							END
						ELSE TKA.Account3 END, 'DD', TRK.div_code) AS Account3
						,CASE WHEN TKA.Amount3 IS Null THEN
							CASE WHEN KSO.IsClaim = 1 THEN
								CASE WHEN KSO.NumberOfServices = 3 THEN
									 CASE WHEN SUBSTRING(KSO.ServiceTypes, 3, 1) = 'M' THEN AmntMR - (AmntMR - TKA.InvoiceTotal) ELSE AmntTires - (AmntTires - TKA.InvoiceTotal) END
								ELSE Null END
							ELSE
								CASE WHEN KSO.NumberOfServices = 3 THEN
									 CASE WHEN SUBSTRING(KSO.ServiceTypes, 3, 1) = 'M' THEN AmntMR - (AmntMR - TKA.InvoiceTotal)
										  WHEN SUBSTRING(KSO.ServiceTypes, 3, 1) = 'T' THEN AmntTires - (AmntTires - TKA.InvoiceTotal)
										  WHEN SUBSTRING(KSO.ServiceTypes, 3, 1) = 'P' THEN AmntPeopleNet - (AmntPeopleNet - TKA.InvoiceTotal)
									 ELSE Null END
								ELSE Null END
							END
						ELSE TKA.Amount3 END AS Amount3
						,CASE WHEN TKA.Description3 IS Null THEN
							CASE WHEN KSO.IsClaim = 1 THEN
								CASE WHEN KSO.NumberOfServices = 3 THEN
									 CASE WHEN SUBSTRING(KSO.ServiceTypes, 3, 1) = 'M' THEN DescMR ELSE DescTires END
								ELSE Null END
							ELSE
								CASE WHEN KSO.NumberOfServices = 3 THEN
									 CASE WHEN SUBSTRING(KSO.ServiceTypes, 3, 1) = 'M' THEN DescMR
										  WHEN SUBSTRING(KSO.ServiceTypes, 3, 1) = 'T' THEN DescTires
										  WHEN SUBSTRING(KSO.ServiceTypes, 3, 1) = 'P' THEN DescPeopleNet
									 ELSE Null END
								ELSE Null END
							END
						ELSE TKA.Description3 END AS Description3
						,TKA.AcctApproved
						,PopUp
			FROM	View_KarmakIntegration TKA
					INNER JOIN [LENSAKMK001\SQLEXPRESS].ILS_Data.dbo.View_SalesOrders KSO ON TKA.InvoiceNumber = KSO.InvoiceNumber
					LEFT JOIN ##curTrucks TRK ON KSO.UnitNumber = TRK.UnitNumber
			WHERE	TKA.Processed = 2
					AND TKA.CustomerNumber NOT IN ('AIS','GIS','RCMR')
					AND TKA.InvoiceTotal > 0
					AND TKA.InvoiceNumber = @InvoiceNumber
			) RECS
	WHERE	KarmakIntegration.InvoiceNumber = RECS.InvoiceNumber
	
	FETCH FROM KarmakInvoices INTO @InvoiceNumber
END

CLOSE KarmakInvoices
DEALLOCATE KarmakInvoices

DROP TABLE ##curTrucks

/*
SELECT * FROM KarmakAccounts
*/