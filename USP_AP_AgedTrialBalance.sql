/*
EXECUTE USP_AP_AgedTrialBalance '02/01/2020'
*/
ALTER PROCEDURE [dbo].[USP_AP_AgedTrialBalance] 
	@AsOfDate Date = NULL
AS 
BEGIN 
    SET NOCOUNT ON;

    IF @AsOfDate IS NULL 
		SET @AsOfDate = GETDATE() 

    -- Insert statements for procedure here 
    SELECT	PMTrans.VendorId, 
            VendorMaster.VendName AS VendorName, 
            PMTrans.vchrnmbr AS VoucherNum, 
            PMTrans.docdate AS DocDate, 
            CASE PMTrans.doctype 
				WHEN 1 THEN 'Invoice' 
				WHEN 2 THEN 'Finance Charge' 
				WHEN 3 THEN 'Misc Charge' 
				END AS DocType, 
            PMTrans.docamnt AS DocAmnt, 
            PMTrans.DocNumbr, 
            ApplyTo.AppldAmt, 
            CASE WHEN pstgdate BETWEEN Dateadd(d, -30, @AsOfDate) AND @AsOfDate THEN PMTrans.docamnt - Isnull(ApplyTo.appldamt, 0) 
				ELSE 0 END AS amt0to30, 
            CASE WHEN pstgdate BETWEEN Dateadd(d, -60, @AsOfDate) AND Dateadd(d, -31, @AsOfDate) 
				THEN PMTrans.docamnt - Isnull(ApplyTo.appldamt, 0) 
				ELSE 0 
				END AS amt31to60, 
            CASE WHEN pstgdate BETWEEN Dateadd(d, -90, @AsOfDate) AND Dateadd(d, -61, @AsOfDate) 
				THEN PMTrans.docamnt - Isnull(ApplyTo.appldamt, 0) 
				ELSE 0 END AS amt61to90, 
            CASE 
            WHEN pstgdate < Dateadd(d, -90, @AsOfDate) THEN PMTrans.docamnt - 
            Isnull(ApplyTo.appldamt, 0) 
            ELSE 0 
            END             AS amtOver91, 
            bachnumb 
	FROM	PM20000 PMTrans 
            INNER JOIN PM00200 VendorMaster ON VendorMaster.vendorid = PMTrans.vendorid 
            LEFT JOIN (SELECT aptvchnm, 
                            aptodcty, 
                            Sum(appldamt) AS appldamt 
                    FROM   pm20100 
                    WHERE  docdate <= @AsOfDate 
                    GROUP  BY aptvchnm, aptodcty) ApplyTo 
                ON PMTrans.vchrnmbr = ApplyTo.aptvchnm 
                    AND PMTrans.doctype = ApplyTo.aptodcty 
    WHERE  pstgdate <= @AsOfDate 
            AND PMTrans.docamnt - Isnull(ApplyTo.appldamt, 0) <> 0 
            AND PMTrans.doctype <= 3 
            AND voided = 0 
    UNION 
    SELECT PMTrans.vendorid, 
            VendorMaster.vendname, 
            PMTrans.vchrnmbr, 
            PMTrans.docdate, 
            CASE PMTrans.doctype 
            WHEN 4 THEN 'Return' 
            WHEN 5 THEN 'Credit' 
            WHEN 6 THEN 'Payment' 
            ELSE CONVERT(VARCHAR(2), PMTrans.doctype) 
            END                                          AS docType, 
            -PMTrans.docamnt                             AS docamnt, 
            PMTrans.docnumbr, 
            ApplyTo.appldamt, 
            -PMTrans.docamnt + Isnull(ApplyTo.appldamt, 0) AS amt0to30, 
            0                                            AS amt31to60, 
            0                                            AS amt61to90, 
            0                                            AS amtOver91, 
            bachnumb 
    FROM   pm20000 PMTrans 
            LEFT JOIN pm00200 VendorMaster 
                ON VendorMaster.vendorid = PMTrans.vendorid 
            LEFT JOIN (SELECT vchrnmbr, 
                            doctype, 
                            Sum(appldamt) AS appldamt 
                    FROM   pm20100 
                    WHERE  docdate <= @AsOfDate 
                    GROUP  BY vchrnmbr, 
                                doctype) ApplyTo 
                ON PMTrans.vchrnmbr = ApplyTo.vchrnmbr 
                    AND PMTrans.doctype = ApplyTo.doctype 
    WHERE  pstgdate <= @AsOfDate 
            AND PMTrans.docamnt - Isnull(ApplyTo.appldamt, 0) <> 0 
            AND PMTrans.doctype >= 4 
            AND voided = 0 
    UNION 
    SELECT PMTrans.vendorid, 
            VendorMaster.vendname, 
            PMTrans.vchrnmbr, 
            PMTrans.docdate, 
            CASE PMTrans.doctype 
            WHEN 1 THEN 'Invoice' 
            WHEN 2 THEN 'Finance Charge' 
            WHEN 3 THEN 'Misc Charge' 
            END             AS docType, 
            PMTrans.docamnt AS docamnt, 
            PMTrans.docnumbr, 
            ApplyTo.appldamt, 
            CASE 
            WHEN pstgdate BETWEEN Dateadd(d, -30, @AsOfDate) AND @AsOfDate THEN 
            PMTrans.docamnt - Isnull(ApplyTo.appldamt, 0) 
            ELSE 0 
            END             AS amt0to30, 
            CASE 
            WHEN pstgdate BETWEEN Dateadd(d, -60, @AsOfDate) AND 
                                    Dateadd(d, -31, @AsOfDate) 
            THEN 
            PMTrans.docamnt - Isnull(ApplyTo.appldamt, 0) 
            ELSE 0 
            END             AS amt31to60, 
            CASE 
            WHEN pstgdate BETWEEN Dateadd(d, -90, @AsOfDate) AND 
                                    Dateadd(d, -61, @AsOfDate) 
            THEN 
            PMTrans.docamnt - Isnull(ApplyTo.appldamt, 0) 
            ELSE 0 
            END             AS amt61to90, 
            CASE 
            WHEN pstgdate < Dateadd(d, -90, @AsOfDate) THEN PMTrans.docamnt - 
            Isnull(ApplyTo.appldamt, 0) 
            ELSE 0 
            END             AS amtOver91, 
            bachnumb 
    FROM   pm30200 PMTrans 
            LEFT JOIN pm00200 VendorMaster 
                ON VendorMaster.vendorid = PMTrans.vendorid 
            LEFT JOIN (SELECT aptvchnm, 
                            aptodcty, 
                            Sum(appldamt) AS appldamt 
                    FROM   pm30300 
                    WHERE  glpostdt <= @AsOfDate 
                    GROUP  BY aptvchnm, 
                                aptodcty) ApplyTo 
                ON ApplyTo.aptvchnm = PMTrans.vchrnmbr 
                    AND PMTrans.doctype = ApplyTo.aptodcty 
    WHERE  pstgdate <= @AsOfDate 
            AND PMTrans.docamnt - Isnull(ApplyTo.appldamt, 0) <> 0 
            AND PMTrans.doctype <= 3 
            AND voided = 0 
    UNION 
    SELECT PMTrans.vendorid, 
            VendorMaster.vendname, 
            PMTrans.vchrnmbr, 
            PMTrans.docdate, 
            CASE PMTrans.doctype 
            WHEN 4 THEN 'Return' 
            WHEN 5 THEN 'Credit' 
            WHEN 6 THEN 'Payment' 
            ELSE CONVERT(VARCHAR(2), PMTrans.doctype) 
            END                                          AS docType, 
            -PMTrans.docamnt                             AS docamnt, 
            PMTrans.docnumbr, 
            ApplyTo.appldamt, 
            -PMTrans.docamnt + Isnull(ApplyTo.appldamt, 0) AS amt0to30, 
            0                                            AS amt31to60, 
            0                                            AS amt61to90, 
            0                                            AS amtOver91, 
            bachnumb 
    FROM   pm30200 PMTrans 
            LEFT JOIN pm00200 VendorMaster 
                ON VendorMaster.vendorid = PMTrans.vendorid 
            LEFT JOIN (SELECT vchrnmbr, 
                            doctype, 
                            Sum(appldamt) AS appldamt 
                    FROM   pm30300 
                    WHERE  glpostdt <= @AsOfDate 
                    GROUP  BY vchrnmbr, 
                                doctype) ApplyTo 
                ON PMTrans.vchrnmbr = ApplyTo.vchrnmbr 
                    AND PMTrans.doctype = ApplyTo.doctype 
    WHERE  pstgdate <= @AsOfDate 
            AND PMTrans.docamnt - Isnull(ApplyTo.appldamt, 0) <> 0 
            AND PMTrans.doctype >= 4 
            AND voided = 0 
    ORDER  BY bachnumb 
END