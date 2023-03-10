/*
EXECUTE GPCustom.dbo.USP_Report_PayrollNotice 'IILS','IILS_2013061401',5203,NULL
EXECUTE GPCustom.dbo.USP_Report_PayrollNotice 'IMC',NULL,6991,NULL
*/
ALTER PROCEDURE [dbo].[USP_Report_PayrollNotice]
	@Company	Char(6),
	@BatchId	Char(15) = Null,
	@NoticeId	Int = Null,
	@EmpName	Varchar(30) = Null
AS
SELECT	*
FROM	(
SELECT	DISTINCT PayrollNoticeId, 
		BatchId, 
		PN.Company,
		AC.CmpnyNam,
		PN.EmployeeId,
		ISNULL(AE.EmployeeName, PN.EmployeeName) AS EmployeeName,
		NoticeType, 
		EmploymentDate,
		PN.EffectiveDate, 
		PN.Supervisor,
		SU.Supervisor AS NewSupervisorName,
		PN.Location,
		LO.LocatnnM AS NewLocation,
		PN.GridClassification,
		GT1.JobPosition AS CurrentGridClass,
		GT1.MinSalary AS CurrentMinSalary,
		GT1.MidSalary AS CurrentMidSalary,
		GT1.MaxSalary AS CurrentMaxSalary,
		GT2.JobPosition AS NewGridClass,
		GT2.MinSalary AS NewMinSalary,
		GT2.MidSalary AS NewMidSalary,
		GT2.MaxSalary AS NewMaxSalary,
		PN.DOLStatus, 
		PEM.DOL_Status AS NewDOLStatus,
		PN.MBO_Eligible, 
		PN.MBO_Percentage,
		PE.MBO_Eligible AS MBO_Eligible_Current,
		PE.MBO_Percentage AS MBO_Percentage_Current,
		DepartmentId AS CurrentDepartment,
		DepartmentName AS CurrentDeptoName,
		SupervisorName AS CurrentSupervisorName,
		AE.JobTitle AS CurrentJobTitle,
		AE.LocationName AS CurrentLocation,
		AE.EmploymentType,
		CASE WHEN AE.EmploymentType = 1 THEN 'FT' ELSE 'PT' END AS CurrentFTPT,
		AE.Hourly,
		PN.Department,
		DEP.Dscriptn AS NewDepartmentName,
		PN.JobPosition,
		JBP.Dscriptn AS NewJobTitle,
		PN.Amount, 
		PN.Anual, 
		PN.Increase,
		CASE WHEN PN.FTPT = 'F' THEN 'FT' WHEN PN.FTPT IS NULL THEN '' ELSE 'PT' END AS FTPT, 
		PN.Comments, 
		PN.RecommendedBy, 
		PN.ApprovedBy1, 
		PN.ApprovedBy2, 
		PN.Submitted, 
		PN.EnteredBy, 
		PN.EnteredOn, 
		PN.ChangedBy, 
		PN.ChangedOn,
		WH.PayRcord, 
		WH.EffectiveDate_I, 
		WH.PayRtAmt,
		WH.PayUnPer AS PeriodDays,
		WH.PayUnit, 
		WH.PayPrPrd, 
		WH.AnnualSalary_I, 
		WH.ChangeReason_I,
		LH.PayRtAmt AS CurrentPayRtAmt,
		LH.PayUnit AS CurrentPayUnit, 
		LH.PayPrPrd AS CurrentPayPrPrd, 
		LH.AnnualSalary_I AS CurrentAnnualSalary,
		ISNULL(RowHistory, 0) AS RowHistory,
		LastSalary,
		CASE WHEN UPR40600.PAYUNPER = 1 THEN 7 ELSE 14 END AS DaysPerPayPeriod
FROM	GPCustom.dbo.PayrollNotice PN
		LEFT JOIN View_AllEmployees AE ON PN.EmployeeId = AE.EmployId
		INNER JOIN Dynamics.dbo.View_AllCompanies CO ON CO.InterId = DB_NAME()
		LEFT JOIN GPCustom.dbo.Payroll_Employees PE ON PN.EmployeeId = PE.EmployeeId AND PE.Company = RTRIM(@Company)
		LEFT JOIN UPR41700 SU ON PN.Supervisor = SU.SupervisorCode_I
		LEFT JOIN SY00600 LO ON PN.Location = LO.LocatnId AND CO.CmpanyId = LO.CmpanyId
		LEFT JOIN UPR40300 DEP ON PN.Department = DEP.DeprtMnt
		LEFT JOIN UPR40301 JBP ON PN.JobPosition = JBP.JobTitle
		LEFT JOIN Dynamics.dbo.View_AllCompanies AC ON PN.Company = AC.InterId
		LEFT JOIN UPR00100 ON UPR00100.EMPLOYID = AE.EmployId
		LEFT JOIN UPR40600 ON UPR00100.Primary_Pay_Record = UPR40600.PAYRCORD
		LEFT JOIN (	
					SELECT	RowHistory = (	SELECT	COUNT(H1.EmployId) + 1
											FROM 	(SELECT	DISTINCT HR.EmployId, PayRcord, EffectiveDate_I, PayRtAmt, PayUnit, PayPrPrd, PayUnPer, AnnualSalary_I 
														FROM	HRPSLH01 HR
																INNER JOIN View_AllEmployees VE ON HR.EmployId = VE.EmployId AND VE.PrimaryPayCode = HR.PayRcord) H1 
														WHERE 	HR.EffectiveDate_I < H1.EffectiveDate_I 
																AND HR.PayRcord = H1.PayRcord 
																AND HR.EmployId = H1.EmployId),
												LastSalary = (SELECT ISNULL(MAX(PayRtAmt), 0.0) FROM HRPSLH01 H2 WHERE HR.EffectiveDate_I > H2.EffectiveDate_I AND HR.PayRcord = H2.PayRcord AND HR.EmployId = H2.EmployId),
												HR.EmployId, 
												HR.PayRcord, 
												HR.EffectiveDate_I, 
												HR.PayRtAmt, 
												HR.PayUnit, 
												HR.PayPrPrd,
												HR.PayUnPer, 
												HR.AnnualSalary_I, 
												ChangeReason_I = (	SELECT	MAX(ChangeReason_I) FROM HRPSLH01 RR WHERE RR.ChangeReason_I <> 'Weekly to Bi Weekly' AND HR.EffectiveDate_I = RR.EffectiveDate_I AND HR.PayRcord = RR.PayRcord AND HR.EmployId = RR.EmployId)
																	FROM 	(SELECT	DISTINCT HR.EmployId, PayRcord, EffectiveDate_I, PayRtAmt, PayUnit, PayPrPrd, PayUnPer, AnnualSalary_I 
																			 FROM	HRPSLH01 HR
																					INNER JOIN View_AllEmployees VE ON HR.EmployId = VE.EmployId AND HR.AnnualSalary_I > 0 --VE.PrimaryPayCode = HR.PayRcord
																			) HR
																	INNER JOIN View_AllEmployees VE ON HR.EmployId = VE.EmployId AND VE.PrimaryPayCode = HR.PayRcord
				) WH ON PN.EmployeeId = WH.EmployId AND ISNULL(WH.EffectiveDate_I, '01/01/1980') < ISNULL(PN.EffectiveDate, GETDATE())

		LEFT JOIN (	SELECT 	HR.EmployId, 
							HR.PayRtAmt,
							HR.PayUnit, 
							HR.PayPrPrd, 
							MAX(HR.AnnualSalary_I) AS AnnualSalary_I, 
							MAX(HR.EffectiveDate_I) AS EffectiveDate
					FROM 	HRPSLH01 HR
							INNER JOIN View_AllEmployees VE ON HR.EmployId = VE.EmployId AND VE.PrimaryPayCode = HR.PayRcord
							INNER JOIN (SELECT 	H1.EmployId, 
												MAX(H1.CHANGEDATE_I) AS CHANGEDATE_I
										FROM 	HRPSLH01 H1
												INNER JOIN View_AllEmployees VE ON H1.EmployId = VE.EmployId AND VE.PrimaryPayCode = H1.PayRcord
										GROUP BY H1.EmployId) 
										W1 ON HR.EmployId = W1.EmployId AND HR.CHANGEDATE_I = W1.CHANGEDATE_I
					GROUP BY HR.EmployId, 
							HR.PayRtAmt,
							HR.PayUnit, 
							HR.PayPrPrd
					) LH ON PN.EmployeeId = LH.EmployId

		LEFT JOIN GPCustom.dbo.Payroll_Employees PEM ON PN.EmployeeId = PEM.EmployeeId AND PN.Company = PEM.Company
		LEFT JOIN GPCustom.dbo.Payroll_GridTitle GT1 ON PEM.GridClassification = GT1.Payroll_GridTitleId
		LEFT JOIN GPCustom.dbo.Payroll_GridTitle GT2 ON PN.GridClassification = GT2.Payroll_GridTitleId
WHERE	(@BatchId IS Null AND @NoticeId IS NOT Null AND PayrollNoticeId = @NoticeId)
		OR (@BatchId IS NOT Null AND BatchId = @BatchId)
		OR (@BatchId IS NOT Null AND @EmpName IS NOT Null AND PN.EmployeeName = @EmpName)
		AND (RowHistory BETWEEN 0 AND 4)) RECS
WHERE	RowHistory BETWEEN 0 AND 4
		AND (@BatchId IS Null OR (@BatchId IS NOT Null AND BatchId = @BatchId))
		AND (@EmpName IS Null OR (@EmpName IS NOT Null AND EmployeeName = @EmpName))
		AND (@NoticeId IS Null OR (@NoticeId IS NOT Null AND PayrollNoticeId = @NoticeId))
ORDER BY EmployeeId, EffectiveDate_I

-- EXECUTE GPCustom.dbo.USP_Report_PayrollNotice 'IILS','IILS_2010053001',NULL,NULL
-- EXECUTE USP_Report_PayrollNotice NULL, 2
-- EXECUTE USP_Report_PayrollNotice 'IMC',NULL,1696,NULL
-- SELECT * FROM View_AllEmployees
-- SELECT * FROM SY00600
-- SELECT * FROM Dynamics.dbo.View_AllCompanies