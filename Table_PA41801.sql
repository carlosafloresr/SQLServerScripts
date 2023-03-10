if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PA41801]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[PA41801]
GO

CREATE TABLE [dbo].[PA41801] (
	[PAsetupkey] [smallint] NOT NULL ,
	[PAtsdefinedprompt1] [char] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PAtsdefinedprompt2] [char] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PAcostdescts] [char] (21) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PATSdoccounter] [char] (17) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PAtsunitcostfrom] [smallint] NOT NULL ,
	[PAtsprofittypefrom] [smallint] NOT NULL ,
	[PAdescriptionfrom] [smallint] NOT NULL ,
	[PAreportingperiods] [smallint] NOT NULL ,
	[PAnumofreportingperiods] [smallint] NOT NULL ,
	[PA1stdatereportperiod] [datetime] NOT NULL ,
	[PAallow_1] [tinyint] NOT NULL ,
	[PAallow_2] [tinyint] NOT NULL ,
	[PAallow_3] [tinyint] NOT NULL ,
	[PAallow_4] [tinyint] NOT NULL ,
	[PAallow_5] [tinyint] NOT NULL ,
	[PAallow_6] [tinyint] NOT NULL ,
	[PAallow_7] [tinyint] NOT NULL ,
	[PAallow_8] [tinyint] NOT NULL ,
	[PAallow_9] [tinyint] NOT NULL ,
	[PAallow_10] [tinyint] NOT NULL ,
	[PAallow_11] [tinyint] NOT NULL ,
	[PAallow_12] [tinyint] NOT NULL ,
	[PAallow_13] [tinyint] NOT NULL ,
	[PAdexcriptionoptions_1] [char] (51) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PAdexcriptionoptions_2] [char] (51) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PAdexcriptionoptions_3] [char] (51) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PAdexcriptionoptions_4] [char] (51) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PAdexcriptionoptions_5] [char] (51) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PAdexcriptionoptions_6] [char] (51) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PAdexcriptionoptions_7] [char] (51) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PAdexcriptionoptions_8] [char] (51) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PAdexcriptionoptions_9] [char] (51) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PAdexcriptionoptions_10] [char] (51) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PAdexcriptionoptions_11] [char] (51) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PAdexcriptionoptions_12] [char] (51) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PAdexcriptionoptions_13] [char] (51) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PApasswordoptions_1] [char] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PApasswordoptions_2] [char] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PApasswordoptions_3] [char] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PApasswordoptions_4] [char] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PApasswordoptions_5] [char] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PApasswordoptions_6] [char] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PApasswordoptions_7] [char] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PApasswordoptions_8] [char] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PApasswordoptions_9] [char] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PApasswordoptions_10] [char] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PApasswordoptions_11] [char] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PApasswordoptions_12] [char] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PApasswordoptions_13] [char] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PAPost_to_Payroll] [tinyint] NOT NULL ,
	[PAPosting_Payroll_Code] [smallint] NOT NULL ,
	[PA_Update_Periodic_Opt] [smallint] NOT NULL ,
	[DEX_ROW_ID] [int] IDENTITY (1, 1) NOT NULL 
) ON [PRIMARY]
GO

setuser
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA41801].[PA_Update_Periodic_Opt]'
GO

EXEC sp_bindefault N'[dbo].[GPS_DATE]', N'[PA41801].[PA1stdatereportperiod]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA41801].[PAallow_1]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA41801].[PAallow_10]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA41801].[PAallow_11]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA41801].[PAallow_12]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA41801].[PAallow_13]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA41801].[PAallow_2]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA41801].[PAallow_3]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA41801].[PAallow_4]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA41801].[PAallow_5]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA41801].[PAallow_6]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA41801].[PAallow_7]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA41801].[PAallow_8]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA41801].[PAallow_9]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA41801].[PAcostdescts]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA41801].[PAdescriptionfrom]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA41801].[PAdexcriptionoptions_1]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA41801].[PAdexcriptionoptions_10]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA41801].[PAdexcriptionoptions_11]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA41801].[PAdexcriptionoptions_12]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA41801].[PAdexcriptionoptions_13]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA41801].[PAdexcriptionoptions_2]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA41801].[PAdexcriptionoptions_3]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA41801].[PAdexcriptionoptions_4]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA41801].[PAdexcriptionoptions_5]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA41801].[PAdexcriptionoptions_6]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA41801].[PAdexcriptionoptions_7]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA41801].[PAdexcriptionoptions_8]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA41801].[PAdexcriptionoptions_9]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA41801].[PAnumofreportingperiods]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA41801].[PApasswordoptions_1]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA41801].[PApasswordoptions_10]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA41801].[PApasswordoptions_11]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA41801].[PApasswordoptions_12]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA41801].[PApasswordoptions_13]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA41801].[PApasswordoptions_2]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA41801].[PApasswordoptions_3]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA41801].[PApasswordoptions_4]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA41801].[PApasswordoptions_5]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA41801].[PApasswordoptions_6]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA41801].[PApasswordoptions_7]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA41801].[PApasswordoptions_8]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA41801].[PApasswordoptions_9]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA41801].[PAPost_to_Payroll]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA41801].[PAPosting_Payroll_Code]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA41801].[PAreportingperiods]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA41801].[PAsetupkey]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA41801].[PAtsdefinedprompt1]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA41801].[PAtsdefinedprompt2]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA41801].[PATSdoccounter]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA41801].[PAtsprofittypefrom]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA41801].[PAtsunitcostfrom]'
GO

setuser
GO

