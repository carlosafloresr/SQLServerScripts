USE [msdb]
GO

/****** Object:  Job [FPT Integration]    Script Date: 6/21/2018 11:34:01 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 6/21/2018 11:34:01 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'FPT Integration', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'ATS Team', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Load Data]    Script Date: 6/21/2018 11:34:02 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Load Data', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'declare @ssisstr varchar(8000), @packagename varchar(200)
declare @params varchar(8000)

set @packagename = ''"C:\Projects\SWSLoad\bin\FPT.dtsx"''
set @params = '' ''
set @ssisstr = ''dtexec /FILE '' + @packagename +'' /DECRYPT "ILSmemphis" /MAXCONCURRENT " -1 " /CHECKPOINTING OFF /REPORTING EW ''
set @ssisstr = @ssisstr + '' '' + @params
--print @ssisstr

DECLARE @returncode int
EXEC @returncode = xp_cmdshell @ssisstr
select @returncode', 
		@database_name=N'Integrations', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Update Status]    Script Date: 6/21/2018 11:34:02 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Update Status', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'/* Grab the Batch and Company from the Transactions Table */
SELECT A.batch , A.Company
INTO [#FPT_temp] 
FROM (
	Select Distinct(BatchId) AS [batch]
		, Company AS [Company]
	from dbo.FPT_ReceivedHeader
	where Status = -100
) A

/* Update the Status of the Transactions Table */
Update dbo.FPT_ReceivedHeader
SET Status = 0
WHERE Status = -100

/* Insert the Batch and Company into the Integrations Table */
INSERT INTO dbo.ReceivedIntegrations
(Integration, BatchId, Company, ReceivedOn, Status)
SELECT ''FPT'' AS [Integration]
	, batch AS [BatchId]
	, Company AS [Company]
	, GETDATE() AS [ReceivedOn]
	, 0 AS [Status]
FROM #FPT_temp

/* Drop the Temporary Table */
DROP TABLE #FPT_temp

EXECUTE USP_FindIntegrations', 
		@database_name=N'Integrations', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Daily', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=30, 
		@freq_subday_type=4, 
		@freq_subday_interval=5, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20081203, 
		@active_end_date=99991231, 
		@active_start_time=70000, 
		@active_end_time=183000, 
		@schedule_uid=N'5d897135-5ac5-4e69-b649-e8afe1e70f14'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


