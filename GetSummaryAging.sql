USE [CollectIT]
GO
/****** Object:  StoredProcedure [dbo].[GetSummaryAging]    Script Date: 12/19/2016 4:24:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[GetSummaryAging]
AS
BEGIN
    SET NOCOUNT ON;

--update CS_Payment set EntityNum = ''
--update CS_Invoice set EntityNum = ''

  DELETE app
    --select * 
    FROM CS_Applied app
    JOIN (
        SELECT *
        FROM (
            SELECT InvoiceId
                ,COUNT(*) [grouping]
                ,Amount
                ,MAX(app.AppliedId) appId
                ,PaymentId
            FROM CS_Applied app
            GROUP BY InvoiceId
                ,Amount
                ,PaymentId
            ) a
        WHERE a.grouping > 1
        ) a ON a.appId = app.AppliedId

    UPDATE pay
    SET OriginalAmount = isnull((
                SELECT Sum(app1.Amount)
                FROM CS_Applied app1
                WHERE app1.PaymentId = pay.PaymentId
                ), 0)
        ,RemainingAmount = isnull((
                SELECT SUM(app2.Amount)
                FROM CS_Applied app2
                WHERE app2.PaymentId = pay.PaymentId
                    AND app2.InvoiceId IS NULL
                ), 0)
    FROM CS_Payment pay

    UPDATE inv
    SET TotalAmountPaid = isnull((
                SELECT Sum(a.Amount)
                FROM (
                    SELECT dbo.ConvertCurrency(app.Amount, pay.CurrencyId, inv.CurrencyId) AS Amount
                    FROM CS_Applied app
                    JOIN CS_Payment pay ON app.PaymentId = pay.PaymentId
                    WHERE app.InvoiceId = inv.InvoiceId
                    ) a
                ), 0)
        ,TotalAmountDue = inv.Amount - isnull((
                SELECT Sum(a.Amount)
                FROM (
                    SELECT dbo.ConvertCurrency(app.Amount, pay.CurrencyId, inv.CurrencyId) AS Amount
                    FROM CS_Applied app
                    JOIN CS_Payment pay ON app.PaymentId = pay.PaymentId
                    WHERE app.InvoiceId = inv.InvoiceId
                    ) a
                ), 0)
    FROM cs_invoice inv

    UPDATE inv
    SET PaymentStatus = CASE 
            WHEN TotalAmountDue = 0
                THEN 1
            ELSE 2
            END
        ,PaidDate = CASE 
            WHEN TotalAmountDue = 0
                THEN (
                        SELECT MAX(pay.PayDate)
                        FROM CS_Payment pay
                        JOIN CS_Applied app ON pay.PaymentId = app.PaymentId
                        WHERE app.InvoiceId = inv.InvoiceId
                        )
            ELSE NULL
            END
    FROM CS_Invoice inv

    UPDATE inv
    SET		PaymentStatus = 1
			,TotalAmountDue = 0
			,TotalAmountPaid = inv.Amount
    FROM	cs_invoice inv
			JOIN CS_Enterprise ent ON inv.EnterpriseId = ent.EnterpriseId
			JOIN (
					SELECT	*
					FROM	[Staging.Invoice]
					WHERE	PaymentStatus = 1
				 ) staInv ON rtrim(inv.InvoiceNum) = (staInv.InvoiceNum) AND rtrim(inv.customerNumber) = rtrim(staInv.CustNum) AND rtrim(ent.EnterpriseNumber) = rtrim(staInv.EnterpriseNum)

    DECLARE @CurDefault INT

    SET @CurDefault = (
            SELECT TOP 1 DefaultCurrencyId
            FROM CS_Settings
            )

    DELETE
    FROM Summary_Aging

    INSERT Summary_Aging (
        UserId
        ,CustomerId
        ,Enterprise
        ,CustomerNum
        ,CustomerName
        ,Bucket1
        ,Bucket2
        ,Bucket3
        ,Bucket4
        ,Bucket5
        ,Bucket6
        ,Bucket7
        ,Bucket8
        ,Bucket9
        ,Bucket10
        ,Total
        ,InvoiceNum
        ,Currency
        )
    SELECT isnull(UserId, 1)
        ,customerid
        ,EnterpriseName
        ,customernumber
        ,companyname
        ,(SUM(bucket1) + MAX(CredBuck1)) Bucket1
        ,(SUM(bucket2) + MAX(CredBuck2)) Bucket2
        ,(SUM(bucket3) + MAX(CredBuck3)) Bucket3
        ,(SUM(bucket4) + MAX(CredBuck4)) Bucket4
        ,(SUM(bucket5) + MAX(CredBuck5)) Bucket5
        ,(SUM(bucket6) + MAX(CredBuck6)) Bucket6
        ,(SUM(bucket7) + MAX(CredBuck7)) Bucket7
        ,(SUM(bucket8) + MAX(CredBuck8)) Bucket8
        ,(SUM(bucket9) + MAX(CredBuck9)) Bucket9
        ,(SUM(bucket10) + MAX(CredBuck10)) Bucket10
        ,((SUM(bucket1) + MAX(CredBuck1)) + (SUM(bucket2) + MAX(CredBuck2)) + (SUM(bucket3) + MAX(CredBuck3)) + (SUM(bucket4) + MAX(CredBuck4)) + (SUM(bucket5) + MAX(CredBuck5)) + (SUM(bucket6) + MAX(CredBuck6)) + (SUM(bucket7) + MAX(CredBuck7)) + (SUM(bucket8) + MAX(CredBuck8)) + (SUM(bucket9) + MAX(CredBuck9)) + (SUM(bucket10) + MAX(CredBuck10))) AS Total
        ,COUNT(CustomerId) AS InvoiceNum
        ,@CurDefault
    FROM (
        SELECT cust.CustomerId
            ,ent.EnterpriseName
            ,cust.CustomerNumber
            ,cust.CompanyName
            ,acct.UserID
            ,CASE 
                WHEN (
                        SELECT datediff(day, inv.DocDate, GETDATE())
                        ) >= (
                        SELECT [from]
                        FROM cs_agingbucket
                        WHERE agingdetailid = 1
                            AND [from] <> 0
                        )
                    AND (
                        SELECT datediff(day, inv.DocDate, GETDATE())
                        ) <= (
                        SELECT [to]
                        FROM cs_agingbucket
                        WHERE agingdetailid = 1
                            --AND [to] <> 0
                        )
                    THEN dbo.ConvertCurrency(inv.TotalAmountDue, inv.CurrencyId, @CurDefault)
                ELSE 0
                END Bucket1
            ,CASE 
                WHEN (
                        SELECT datediff(day, inv.DocDate, GETDATE())
                        ) >= (
                        SELECT [from]
                        FROM cs_agingbucket
                        WHERE agingdetailid = 2
                            AND [from] <> 0
                        )
                    AND (
                        SELECT datediff(day, inv.DocDate, GETDATE())
                        ) <= (
                        SELECT [to]
                        FROM cs_agingbucket
                        WHERE agingdetailid = 2
                            AND [to] <> 0
                        )
                    THEN dbo.ConvertCurrency(inv.TotalAmountDue, inv.CurrencyId, @CurDefault)
                ELSE 0
                END Bucket2
            ,CASE 
                WHEN (
                        SELECT datediff(day, inv.DocDate, GETDATE())
                        ) >= (
                        SELECT [from]
                        FROM cs_agingbucket
                        WHERE agingdetailid = 3
                            AND [from] <> 0
                        )
                    AND (
                        SELECT datediff(day, inv.DocDate, GETDATE())
                        ) <= (
                        SELECT [to]
                        FROM cs_agingbucket
                        WHERE agingdetailid = 3
                            AND [to] <> 0
                        )
                    THEN dbo.ConvertCurrency(inv.TotalAmountDue, inv.CurrencyId, @CurDefault)
                ELSE 0
                END Bucket3
            ,CASE 
                WHEN (
                        SELECT datediff(day, inv.DocDate, GETDATE())
                        ) >= (
                        SELECT [from]
                        FROM cs_agingbucket
                        WHERE agingdetailid = 4
                            AND [from] <> 0
                        )
                    AND (
                        SELECT datediff(day, inv.DocDate, GETDATE())
                        ) <= (
                        SELECT [to]
                        FROM cs_agingbucket
                        WHERE agingdetailid = 4
                            AND [to] <> 0
                        )
                    THEN dbo.ConvertCurrency(inv.TotalAmountDue, inv.CurrencyId, @CurDefault)
                ELSE 0
                END Bucket4
            ,CASE 
                WHEN (
                        SELECT datediff(day, inv.DocDate, GETDATE())
                        ) >= (
                        SELECT [from]
                        FROM cs_agingbucket
                        WHERE agingdetailid = 5
                            AND [from] <> 0
                        )
                    AND (
                        SELECT datediff(day, inv.DocDate, GETDATE())
                        ) <= (
                        SELECT [to]
                        FROM cs_agingbucket
                        WHERE agingdetailid = 5
                            AND [to] <> 0
                        )
                    THEN dbo.ConvertCurrency(inv.TotalAmountDue, inv.CurrencyId, @CurDefault)
                ELSE 0
                END Bucket5
            ,CASE 
                WHEN (
                        SELECT datediff(day, inv.DocDate, GETDATE())
                        ) >= (
                        SELECT [from]
                        FROM cs_agingbucket
                        WHERE agingdetailid = 6
                            AND [from] <> 0
                        )
                    AND (
                        SELECT datediff(day, inv.DocDate, GETDATE())
                        ) <= (
                        SELECT [to]
                        FROM cs_agingbucket
                        WHERE agingdetailid = 6
                            AND [to] <> 0
                        )
                    THEN dbo.ConvertCurrency(inv.TotalAmountDue, inv.CurrencyId, @CurDefault)
                ELSE 0
                END Bucket6
            ,CASE 
                WHEN (
                        SELECT datediff(day, inv.DocDate, GETDATE())
                        ) >= (
                        SELECT [from]
                        FROM cs_agingbucket
                        WHERE agingdetailid = 7
                            AND [from] <> 0
                        )
                    AND (
                        SELECT datediff(day, inv.DocDate, GETDATE())
                        ) <= (
                        SELECT [to]
                        FROM cs_agingbucket
                        WHERE agingdetailid = 7
                            AND [to] <> 0
                        )
                    THEN dbo.ConvertCurrency(inv.TotalAmountDue, inv.CurrencyId, @CurDefault)
                ELSE 0
                END Bucket7
            ,CASE 
                WHEN (
                        SELECT datediff(day, inv.DocDate, GETDATE())
                        ) >= (
                        SELECT [from]
                        FROM cs_agingbucket
                        WHERE agingdetailid = 8
                            AND [from] <> 0
                        )
                    AND (
                        SELECT datediff(day, inv.DocDate, GETDATE())
                        ) <= (
                        SELECT [to]
                        FROM cs_agingbucket
                        WHERE agingdetailid = 8
                            AND [to] <> 0
                        )
                    THEN dbo.ConvertCurrency(inv.TotalAmountDue, inv.CurrencyId, @CurDefault)
                ELSE 0
                END Bucket8
            ,CASE 
                WHEN (
                        SELECT datediff(day, inv.DocDate, GETDATE())
                        ) >= (
                        SELECT [from]
                        FROM cs_agingbucket
                        WHERE agingdetailid = 9
                            AND [from] <> 0
                        )
                    AND (
                        SELECT datediff(day, inv.DocDate, GETDATE())
                        ) <= (
                        SELECT [to]
                        FROM cs_agingbucket
                        WHERE agingdetailid = 9
                            AND [to] <> 0
                        )
                    THEN dbo.ConvertCurrency(inv.TotalAmountDue, inv.CurrencyId, @CurDefault)
                ELSE 0
                END Bucket9
            ,CASE 
                WHEN (
                        SELECT datediff(day, inv.DocDate, GETDATE())
                        ) >= (
                        SELECT [from]
                        FROM cs_agingbucket
                        WHERE agingdetailid = 10
                            AND [from] <> 0
                        )
                    AND (
                        SELECT datediff(day, inv.DocDate, GETDATE())
                        ) <= (
                        SELECT [to]
                        FROM cs_agingbucket
                        WHERE agingdetailid = 10
                            AND [to] <> 0
                        )
                    THEN dbo.ConvertCurrency(inv.TotalAmountDue, inv.CurrencyId, @CurDefault)
                ELSE 0
                END Bucket10
            ,isnull(credits.Bucket1, 0) AS CredBuck1
            ,isnull(credits.Bucket2, 0) AS CredBuck2
            ,isnull(credits.Bucket3, 0) AS CredBuck3
            ,isnull(credits.Bucket4, 0) AS CredBuck4
            ,isnull(credits.Bucket5, 0) AS CredBuck5
            ,isnull(credits.Bucket6, 0) AS CredBuck6
            ,isnull(credits.Bucket7, 0) AS CredBuck7
            ,isnull(credits.Bucket8, 0) AS CredBuck8
            ,isnull(credits.Bucket9, 0) AS CredBuck9
            ,isnull(credits.Bucket10, 0) AS CredBuck10
        FROM CS_Customer cust
        LEFT JOIN (
            SELECT *
            FROM CS_Invoice
            WHERE PaymentStatus = 2
            ) inv ON cust.CustomerId = inv.CustomerId
        JOIN CS_Enterprise ent ON cust.EnterpriseId = ent.EnterpriseId
        LEFT JOIN cs_account acct ON cust.customerId = acct.customerId
        LEFT JOIN (
            SELECT cred.CustomerId
                ,- 1 * SUM(isnull(cred.Bucket1, 0)) AS Bucket1
                ,- 1 * SUM(isnull(cred.Bucket2, 0)) AS Bucket2
                ,- 1 * SUM(isnull(cred.Bucket3, 0)) AS Bucket3
                ,- 1 * SUM(isnull(cred.Bucket4, 0)) AS Bucket4
                ,- 1 * SUM(isnull(cred.Bucket5, 0)) AS Bucket5
                ,- 1 * SUM(isnull(cred.Bucket6, 0)) AS Bucket6
                ,- 1 * SUM(isnull(cred.Bucket7, 0)) AS Bucket7
                ,- 1 * SUM(isnull(cred.Bucket8, 0)) AS Bucket8
                ,- 1 * SUM(isnull(cred.Bucket9, 0)) AS Bucket9
                ,- 1 * SUM(isnull(cred.Bucket10, 0)) AS Bucket10
            FROM (
                SELECT pay.CustomerId
                    ,CASE 
                        WHEN (
                                SELECT datediff(day, pay.PayDate, GETDATE())
                                ) >= (
                                SELECT [from]
                                FROM cs_agingbucket
                                WHERE agingdetailid = 1
                                    AND [from] <> 0
                                )
                            AND (
                                SELECT datediff(day, pay.PayDate, GETDATE())
                                ) <= (
                                SELECT [to]
                                FROM cs_agingbucket
                                WHERE agingdetailid = 1
                                    --AND [to] <> 0
                                )
                            THEN dbo.ConvertCurrency(pay.RemainingAmount, pay.CurrencyId, @CurDefault)
                        ELSE 0
                        END Bucket1
                    ,CASE 
                        WHEN (
                                SELECT datediff(day, pay.PayDate, GETDATE())
                                ) >= (
                                SELECT [from]
                                FROM cs_agingbucket
                                WHERE agingdetailid = 2
                                    AND [from] <> 0
                                )
                            AND (
                                SELECT datediff(day, pay.PayDate, GETDATE())
                                ) <= (
                                SELECT [to]
                                FROM cs_agingbucket
                                WHERE agingdetailid = 2
                                    --AND [to] <> 0
                                )
                            THEN dbo.ConvertCurrency(pay.RemainingAmount, pay.CurrencyId, @CurDefault)
                        ELSE 0
                        END Bucket2
                    ,CASE 
                        WHEN (
                                SELECT datediff(day, pay.PayDate, GETDATE())
                                ) >= (
                                SELECT [from]
                                FROM cs_agingbucket
                                WHERE agingdetailid = 3
                                    AND [from] <> 0
                                )
                            AND (
                                SELECT datediff(day, pay.PayDate, GETDATE())
                                ) <= (
                                SELECT [to]
                                FROM cs_agingbucket
                                WHERE agingdetailid = 3
                                    AND [to] <> 0
                                )
                            THEN dbo.ConvertCurrency(pay.RemainingAmount, pay.CurrencyId, @CurDefault)
                        ELSE 0
                        END Bucket3
                    ,CASE 
                        WHEN (
                                SELECT datediff(day, pay.PayDate, GETDATE())
                                ) >= (
                                SELECT [from]
                                FROM cs_agingbucket
                                WHERE agingdetailid = 4
                                    AND [from] <> 0
                                )
                            AND (
                                SELECT datediff(day, pay.PayDate, GETDATE())
                                ) <= (
                                SELECT [to]
                                FROM cs_agingbucket
                                WHERE agingdetailid = 4
                                    AND [to] <> 0
                                )
                            THEN dbo.ConvertCurrency(pay.RemainingAmount, pay.CurrencyId, @CurDefault)
                        ELSE 0
                        END Bucket4
                    ,CASE 
                        WHEN (
                                SELECT datediff(day, pay.PayDate, GETDATE())
                                ) >= (
                                SELECT [from]
                                FROM cs_agingbucket
                                WHERE agingdetailid = 5
                                    AND [from] <> 0
                                )
                            AND (
                                SELECT datediff(day, pay.PayDate, GETDATE())
                                ) <= (
                                SELECT [to]
                                FROM cs_agingbucket
                                WHERE agingdetailid = 5
                                    AND [to] <> 0
                                )
                            THEN dbo.ConvertCurrency(pay.RemainingAmount, pay.CurrencyId, @CurDefault)
                        ELSE 0
                        END Bucket5
                    ,CASE 
                        WHEN (
                                SELECT datediff(day, pay.PayDate, GETDATE())
                                ) >= (
                                SELECT [from]
                                FROM cs_agingbucket
                                WHERE agingdetailid = 6
                                    AND [from] <> 0
                                )
                            AND (
                                SELECT datediff(day, pay.PayDate, GETDATE())
                                ) <= (
                                SELECT [to]
                                FROM cs_agingbucket
                                WHERE agingdetailid = 6
                                    AND [to] <> 0
                                )
                            THEN dbo.ConvertCurrency(pay.RemainingAmount, pay.CurrencyId, @CurDefault)
                        ELSE 0
                        END Bucket6
                    ,CASE 
                        WHEN (
                                SELECT datediff(day, pay.PayDate, GETDATE())
                                ) >= (
                                SELECT [from]
                                FROM cs_agingbucket
                                WHERE agingdetailid = 7
                                    AND [from] <> 0
                                )
                            AND (
                                SELECT datediff(day, pay.PayDate, GETDATE())
                                ) <= (
                                SELECT [to]
                                FROM cs_agingbucket
                                WHERE agingdetailid = 7
                                    AND [to] <> 0
                                )
                            THEN dbo.ConvertCurrency(pay.RemainingAmount, pay.CurrencyId, @CurDefault)
                        ELSE 0
                        END Bucket7
                    ,CASE 
                        WHEN (
                                SELECT datediff(day, pay.PayDate, GETDATE())
                                ) >= (
                                SELECT [from]
                                FROM cs_agingbucket
                                WHERE agingdetailid = 8
                                    AND [from] <> 0
                                )
                            AND (
                                SELECT datediff(day, pay.PayDate, GETDATE())
                                ) <= (
                                SELECT [to]
                                FROM cs_agingbucket
                                WHERE agingdetailid = 8
                                    AND [to] <> 0
                                )
                            THEN dbo.ConvertCurrency(pay.RemainingAmount, pay.CurrencyId, @CurDefault)
                        ELSE 0
                        END Bucket8
                    ,CASE 
                        WHEN (
                                SELECT datediff(day, pay.PayDate, GETDATE())
                                ) >= (
                                SELECT [from]
                                FROM cs_agingbucket
                                WHERE agingdetailid = 9
                                    AND [from] <> 0
                                )
                            AND (
                                SELECT datediff(day, pay.PayDate, GETDATE())
                                ) <= (
                                SELECT [to]
                                FROM cs_agingbucket
                                WHERE agingdetailid = 9
                                    AND [to] <> 0
                                )
                            THEN dbo.ConvertCurrency(pay.RemainingAmount, pay.CurrencyId, @CurDefault)
                        ELSE 0
                        END Bucket9
                    ,CASE 
                        WHEN (
                                SELECT datediff(day, pay.PayDate, GETDATE())
                                ) >= (
                                SELECT [from]
                                FROM cs_agingbucket
                                WHERE agingdetailid = 10
                                    AND [from] <> 0
                                )
                            AND (
                                SELECT datediff(day, pay.PayDate, GETDATE())
                                ) <= (
                                SELECT [to]
                                FROM cs_agingbucket
                                WHERE agingdetailid = 10
                                    AND [to] <> 0
                                )
                            THEN dbo.ConvertCurrency(pay.RemainingAmount, pay.CurrencyId, @CurDefault)
                        ELSE 0
                        END Bucket10
                FROM CS_Payment pay
                WHERE  pay.RemainingAmount <> 0
                ) cred
            GROUP BY cred.CustomerId
            ) credits ON cust.CustomerId = credits.CustomerId
            --WHERE inv.TotalAmountDue > 0
        ) AS AgingDetail
    GROUP BY customerid
        ,customernumber
        ,companyname
        ,UserId
        ,EnterpriseName

	EXECUTE Custom_GetSummaryAging_PostSync
END
