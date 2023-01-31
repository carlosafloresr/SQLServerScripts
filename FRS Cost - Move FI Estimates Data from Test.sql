USE [FI_Data]
GO

TRUNCATE TABLE [FI_Data].[dbo].[FI_EstimatesDetails]
GO

TRUNCATE TABLE [FI_Data].[dbo].[FI_Estimates]
GO

INSERT INTO [FI_Data].[dbo].[FI_Estimates]
		([id]
		,[inv_no]
		,[acct_no]
		,[container]
		,[chassis]
		,[cost]
		,[vendor_id]
		,[genset_no]
		,[post_date])
SELECT	[id]
		,[inv_no]
		,[acct_no]
		,[container]
		,[chassis]
		,[cost]
		,[vendor_id]
		,[genset_no]
		,[post_date]
FROM	[FI_Data_Test].[dbo].[FI_Estimates]
GO

INSERT INTO [FI_Data].[dbo].[FI_EstimatesDetails]
		([EstimateId]
		,[status]
		,[posted]
		,[inv_est]
		,[inv_total]
		,[labor_hour]
		,[labor]
		,[mech_hours]
		,[parts]
		,[cdex_remk]
		,[inv_date]
		,[expire_date]
		,[week_end]
		,[entry_date]
		,[rep_date]
		,[est_date]
		,[import_date]
		,[historical]
		,[ReceivedOn])
SELECT	[EstimateId]
		,[status]
		,[posted]
		,[inv_est]
		,[inv_total]
		,[labor_hour]
		,[labor]
		,[mech_hours]
		,[parts]
		,[cdex_remk]
		,[inv_date]
		,[expire_date]
		,[week_end]
		,[entry_date]
		,[rep_date]
		,[est_date]
		,[import_date]
		,[historical]
		,[ReceivedOn]
FROM	[FI_Data_Test].[dbo].[FI_EstimatesDetails]
GO




