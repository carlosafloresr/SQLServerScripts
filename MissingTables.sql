if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PA41801]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[PA41801]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PA41901]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[PA41901]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PA42001]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[PA42001]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PA42201]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[PA42201]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PA42401]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[PA42401]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PA42501]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[PA42501]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PA42601]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[PA42601]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PA42602]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[PA42602]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PA42701]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[PA42701]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PA42801]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[PA42801]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PA42802]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[PA42802]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PA42901]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[PA42901]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PA42902]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[PA42902]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PA43001]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[PA43001]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PA43002]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[PA43002]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PA43101]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[PA43101]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PA43102]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[PA43102]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GPS_CHAR]') and OBJECTPROPERTY(id, N'IsDefault') = 1)
drop default [dbo].[GPS_CHAR]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GPS_DATE]') and OBJECTPROPERTY(id, N'IsDefault') = 1)
drop default [dbo].[GPS_DATE]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GPS_INT]') and OBJECTPROPERTY(id, N'IsDefault') = 1)
drop default [dbo].[GPS_INT]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GPS_MONEY]') and OBJECTPROPERTY(id, N'IsDefault') = 1)
drop default [dbo].[GPS_MONEY]
GO

 create default dbo.GPS_CHAR AS ''    
GO
 create default dbo.GPS_DATE AS '1/1/1900'    
GO
 create default dbo.GPS_INT AS 0    
GO
 create default dbo.GPS_MONEY AS 0.00    
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

CREATE TABLE [dbo].[PA41901] (
	[PAsetupkey] [smallint] NOT NULL ,
	[PAEQLdefinedprompt1] [char] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PAEQLdefinedprompt2] [char] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PAELcostdesc] [char] (21) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PAEQdoccounter] [char] (17) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PAEQLunitcostfrom] [smallint] NOT NULL ,
	[PAELprofittypefrom] [smallint] NOT NULL ,
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
	[PA_Update_Periodic_Opt] [smallint] NOT NULL ,
	[DEX_ROW_ID] [int] IDENTITY (1, 1) NOT NULL 
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[PA42001] (
	[PAsetupkey] [smallint] NOT NULL ,
	[PAMLdefinedprompt1] [char] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PAMLdefinedprompt2] [char] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PAcostdesceML] [char] (21) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PAMISCLdoccounter] [char] (17) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PAMLunitcostfrom] [smallint] NOT NULL ,
	[PAMLprofittypefrom] [smallint] NOT NULL ,
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
	[PA_Update_Periodic_Opt] [smallint] NOT NULL ,
	[DEX_ROW_ID] [int] IDENTITY (1, 1) NOT NULL 
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[PA42201] (
	[PAsetupkey] [smallint] NOT NULL ,
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
	[PAAllowPOWOPrinting] [tinyint] NOT NULL ,
	[PAbillnoteidx] [numeric](19, 5) NOT NULL ,
	[PAcostdescvi] [char] (21) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PApodeformatouse] [smallint] NOT NULL ,
	[PAdeftopoubitcosts] [tinyint] NOT NULL ,
	[PAdescriptionfrom] [smallint] NOT NULL ,
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
	[PApoformatlabel1] [char] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PApoformatlabel2] [char] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PApoformatlabel3] [char] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
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
	[PAprcntvarianceallowed] [smallint] NOT NULL ,
	[PApostoDynPM] [tinyint] NOT NULL ,
	[PAPriceLevelFromIV] [smallint] NOT NULL ,
	[PAviprofittypefrom] [smallint] NOT NULL ,
	[PApounitostfrom] [smallint] NOT NULL ,
	[PA_Update_Periodic_Opt] [smallint] NOT NULL ,
	[PAvidefinedprompt1] [char] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PAvidefinedprompt2] [char] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[DEX_ROW_ID] [int] IDENTITY (1, 1) NOT NULL 
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[PA42401] (
	[PAsetupkey] [smallint] NOT NULL ,
	[PAerdefinedprompt1] [char] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PAerdefinedprompt2] [char] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PAcostdescer] [char] (21) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PAerdoccounter] [char] (17) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PAVIDROAer] [smallint] NOT NULL ,
	[PAeeprofittypefrom] [smallint] NOT NULL ,
	[PAdescriptionfrom] [smallint] NOT NULL ,
	[USEADVTX] [smallint] NOT NULL ,
	[TAXSCHID] [char] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PAMisc_Taxable_P] [smallint] NOT NULL ,
	[MSCSCHID] [char] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PAFreight_Taxable_P] [smallint] NOT NULL ,
	[FRTSCHID] [char] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
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
	[PAbillnoteidx] [numeric](19, 5) NOT NULL ,
	[PAExpenseType] [smallint] NOT NULL ,
	[PAPaymentMethod] [smallint] NOT NULL ,
	[PApostoDynPM] [tinyint] NOT NULL ,
	[PA_Update_Periodic_Opt] [smallint] NOT NULL ,
	[DEX_ROW_ID] [int] IDENTITY (1, 1) NOT NULL 
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[PA42501] (
	[PA_Billing_Discount_From] [smallint] NOT NULL ,
	[PAsetupkey] [smallint] NOT NULL ,
	[PAbillidocounter] [char] (17) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PARevenue_Doc_Counter] [char] (17) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PAbillerdefinedprompt1] [char] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PAbillerdefinedprompt2] [char] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
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
	[PALog_File] [char] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[USEADVTX] [smallint] NOT NULL ,
	[TAXSCHID] [char] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[NONIVTXB] [smallint] NOT NULL ,
	[NONIVSCH] [char] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[FRGTTXBL] [smallint] NOT NULL ,
	[FRTSCHID] [char] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[MISCTXBL] [smallint] NOT NULL ,
	[MSCSCHID] [char] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PARGApplyTo] [smallint] NOT NULL ,
	[PA_Not_Allow_Qty_Writeup] [tinyint] NOT NULL ,
	[PANotAllowQtyWritedown] [tinyint] NOT NULL ,
	[PAPostoDynRM] [tinyint] NOT NULL ,
	[PA_Currency_To_Use] [smallint] NOT NULL ,
	[PA_Default_Cutoff_Date] [smallint] NOT NULL ,
	[PA_Calc_Retainer_Comm] [tinyint] NOT NULL ,
	[PA_Include_Billed_Fees] [tinyint] NOT NULL ,
	[PA_Retainer_Taxable] [tinyint] NOT NULL ,
	[PA_Update_Periodic_Opt] [smallint] NOT NULL ,
	[PA_Prorate_Cost] [tinyint] NOT NULL ,
	[DEX_ROW_ID] [int] IDENTITY (1, 1) NOT NULL 
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[PA42601] (
	[PABill_Format_Key] [smallint] NOT NULL ,
	[PABillDesc] [char] (41) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PABILLFORMNAME] [char] (51) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PA_Contract_Stick_Pin] [smallint] NOT NULL ,
	[PAprntcontheading1] [tinyint] NOT NULL ,
	[PAprntcontrxbillnotes1] [tinyint] NOT NULL ,
	[PA_Contract_Collating] [smallint] NOT NULL ,
	[PA_Project_Stick_Pin] [smallint] NOT NULL ,
	[PAprntprojheadings1] [tinyint] NOT NULL ,
	[PAprntprojtrxbillnotes1] [tinyint] NOT NULL ,
	[PA_Project_Collating] [smallint] NOT NULL ,
	[PA_Fees_Stick_Pin] [smallint] NOT NULL ,
	[PAFeesDisplayOptions] [smallint] NOT NULL ,
	[PAPrintBillNotesFee] [tinyint] NOT NULL ,
	[PALongFeeNameProject] [char] (101) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PALongFeeNameRetainer] [char] (101) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PALongFeeNameRetentions] [char] (101) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PALongFeeNameService] [char] (101) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PA_Trxs_Stick_Pin] [smallint] NOT NULL ,
	[PAPRNTSUMMTS] [smallint] NOT NULL ,
	[PAPRNTSUMMEL] [smallint] NOT NULL ,
	[PAPRNTSUMMML] [smallint] NOT NULL ,
	[PAPRNTSUMMIV] [smallint] NOT NULL ,
	[PAPRNTSUMMVI] [smallint] NOT NULL ,
	[PAPRNTSUMMEE] [smallint] NOT NULL ,
	[PAPrintSummaryCPFPTS] [smallint] NOT NULL ,
	[PAPrintSummaryCPFPEL] [smallint] NOT NULL ,
	[PAPrintSummaryCPFPML] [smallint] NOT NULL ,
	[PAPrintSummaryCPFPIV] [smallint] NOT NULL ,
	[PAPrintSummaryCPFPVI] [smallint] NOT NULL ,
	[PAPrintSummaryCPFPEE] [smallint] NOT NULL ,
	[PAprntbillnotests1] [tinyint] NOT NULL ,
	[PAprntbillnotesEL] [tinyint] NOT NULL ,
	[PAprntbillnotesML] [tinyint] NOT NULL ,
	[PAprntbillnotesIV] [tinyint] NOT NULL ,
	[PAprntbillnotesvi1] [tinyint] NOT NULL ,
	[PAprntbillnotesee1] [tinyint] NOT NULL ,
	[PAPRNTSORTTS] [smallint] NOT NULL ,
	[PAPRNTSORTEL] [smallint] NOT NULL ,
	[PAPRNTSORTML] [smallint] NOT NULL ,
	[PAPRNTSORTIV] [smallint] NOT NULL ,
	[PAPRNTSORTVI] [smallint] NOT NULL ,
	[PAPRNTSORTEE] [smallint] NOT NULL ,
	[PALongTrxNameTS] [char] (101) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PALongTrxNameEL] [char] (101) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PALongTrxNameML] [char] (101) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PALongTrxNameIV] [char] (101) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PALongTrxNameVI] [char] (101) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PALongTrxNameEE] [char] (101) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PAIFDataPrinted] [smallint] NOT NULL ,
	[DEX_ROW_ID] [int] IDENTITY (1, 1) NOT NULL 
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[PA42602] (
	[PABill_Format_Key] [smallint] NOT NULL ,
	[USERID] [char] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[DEX_ROW_ID] [int] IDENTITY (1, 1) NOT NULL ,
	[PRNSET] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL 
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

CREATE TABLE [dbo].[PA42701] (
	[PAsetupkey] [smallint] NOT NULL ,
	[PAInventory_Counter] [char] (17) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[LOCNCODE] [char] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PAUserDefinedPrompt1IV] [char] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PAUserDefinedPrompt2IV] [char] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PACostDescriptionIV] [char] (21) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PAdescriptionfrom] [smallint] NOT NULL ,
	[PAPriceLevelFromIV] [smallint] NOT NULL ,
	[TRKVDTRX] [tinyint] NOT NULL ,
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
	[PACBNOTRNSFRBILLNTS] [tinyint] NOT NULL ,
	[PADONOTALLIV] [tinyint] NOT NULL ,
	[DEX_ROW_ID] [int] IDENTITY (1, 1) NOT NULL 
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[PA42801] (
	[CUSTCLAS] [char] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PABILLCYCLEID] [char] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PABILLFORMAT] [char] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[DEX_ROW_ID] [int] IDENTITY (1, 1) NOT NULL 
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[PA42802] (
	[CUSTCLAS] [char] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PABILLCYCLEID1] [char] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[DEX_ROW_ID] [int] IDENTITY (1, 1) NOT NULL 
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[PA42901] (
	[PACTID] [char] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PABILLCYCLEID] [char] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PABILLFORMAT] [char] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[DEX_ROW_ID] [int] IDENTITY (1, 1) NOT NULL 
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[PA42902] (
	[PACTID] [char] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PABILLCYCLEID1] [char] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[DEX_ROW_ID] [int] IDENTITY (1, 1) NOT NULL 
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[PA43001] (
	[PAsfid] [smallint] NOT NULL ,
	[PArecordid] [char] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PAcosttrxid] [char] (17) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PAaccttype] [smallint] NOT NULL ,
	[PAACTINDX] [int] NOT NULL ,
	[DEX_ROW_ID] [int] IDENTITY (1, 1) NOT NULL 
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[PA43002] (
	[PAsfid] [smallint] NOT NULL ,
	[PArecordid] [char] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PAcosttrxid] [char] (17) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PAaccttype] [smallint] NOT NULL ,
	[PAACTINDX] [int] NOT NULL ,
	[DEX_ROW_ID] [int] IDENTITY (1, 1) NOT NULL 
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[PA43101] (
	[PA_Bill_Format_Number] [char] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PABILLFORMNAME] [char] (51) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PAcbdefault] [tinyint] NOT NULL ,
	[DEX_ROW_ID] [int] IDENTITY (1, 1) NOT NULL 
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[PA43102] (
	[PA_Bill_Format_Number] [char] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[SEQNUMBR] [int] NOT NULL ,
	[PABill_Format_Key] [smallint] NOT NULL ,
	[DEX_ROW_ID] [int] IDENTITY (1, 1) NOT NULL 
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[PA41801] WITH NOCHECK ADD 
	CONSTRAINT [PKPA41801] PRIMARY KEY  CLUSTERED 
	(
		[PAsetupkey]
	) WITH  FILLFACTOR = 90  ON [PRIMARY] 
GO

ALTER TABLE [dbo].[PA41901] WITH NOCHECK ADD 
	CONSTRAINT [PKPA41901] PRIMARY KEY  CLUSTERED 
	(
		[PAsetupkey]
	) WITH  FILLFACTOR = 90  ON [PRIMARY] 
GO

ALTER TABLE [dbo].[PA42001] WITH NOCHECK ADD 
	CONSTRAINT [PKPA42001] PRIMARY KEY  CLUSTERED 
	(
		[PAsetupkey]
	) WITH  FILLFACTOR = 90  ON [PRIMARY] 
GO

ALTER TABLE [dbo].[PA42201] WITH NOCHECK ADD 
	CONSTRAINT [PKPA42201] PRIMARY KEY  CLUSTERED 
	(
		[PAsetupkey]
	) WITH  FILLFACTOR = 90  ON [PRIMARY] 
GO

ALTER TABLE [dbo].[PA42401] WITH NOCHECK ADD 
	CONSTRAINT [PKPA42401] PRIMARY KEY  CLUSTERED 
	(
		[PAsetupkey]
	) WITH  FILLFACTOR = 90  ON [PRIMARY] 
GO

ALTER TABLE [dbo].[PA42601] WITH NOCHECK ADD 
	CONSTRAINT [PKPA42601] PRIMARY KEY  CLUSTERED 
	(
		[PABill_Format_Key]
	) WITH  FILLFACTOR = 90  ON [PRIMARY] 
GO

ALTER TABLE [dbo].[PA42602] WITH NOCHECK ADD 
	CONSTRAINT [PKPA42602] PRIMARY KEY  CLUSTERED 
	(
		[PABill_Format_Key],
		[USERID]
	) WITH  FILLFACTOR = 90  ON [PRIMARY] 
GO

ALTER TABLE [dbo].[PA42701] WITH NOCHECK ADD 
	CONSTRAINT [PKPA42701] PRIMARY KEY  CLUSTERED 
	(
		[PAsetupkey]
	) WITH  FILLFACTOR = 90  ON [PRIMARY] 
GO

ALTER TABLE [dbo].[PA42801] WITH NOCHECK ADD 
	CONSTRAINT [PKPA42801] PRIMARY KEY  CLUSTERED 
	(
		[CUSTCLAS],
		[PABILLCYCLEID]
	) WITH  FILLFACTOR = 90  ON [PRIMARY] 
GO

ALTER TABLE [dbo].[PA42802] WITH NOCHECK ADD 
	CONSTRAINT [PKPA42802] PRIMARY KEY  CLUSTERED 
	(
		[CUSTCLAS]
	) WITH  FILLFACTOR = 90  ON [PRIMARY] 
GO

ALTER TABLE [dbo].[PA42902] WITH NOCHECK ADD 
	CONSTRAINT [PKPA42902] PRIMARY KEY  CLUSTERED 
	(
		[PACTID]
	) WITH  FILLFACTOR = 90  ON [PRIMARY] 
GO

ALTER TABLE [dbo].[PA41801] ADD 
	 CHECK (datepart(hour,[PA1stdatereportperiod]) = 0 and datepart(minute,[PA1stdatereportperiod]) = 0 and datepart(second,[PA1stdatereportperiod]) = 0 and datepart(millisecond,[PA1stdatereportperiod]) = 0)
GO

ALTER TABLE [dbo].[PA41901] ADD 
	 CHECK (datepart(hour,[PA1stdatereportperiod]) = 0 and datepart(minute,[PA1stdatereportperiod]) = 0 and datepart(second,[PA1stdatereportperiod]) = 0 and datepart(millisecond,[PA1stdatereportperiod]) = 0)
GO

ALTER TABLE [dbo].[PA42001] ADD 
	 CHECK (datepart(hour,[PA1stdatereportperiod]) = 0 and datepart(minute,[PA1stdatereportperiod]) = 0 and datepart(second,[PA1stdatereportperiod]) = 0 and datepart(millisecond,[PA1stdatereportperiod]) = 0)
GO

ALTER TABLE [dbo].[PA42501] ADD 
	CONSTRAINT [PKPA42501] PRIMARY KEY  NONCLUSTERED 
	(
		[PAsetupkey]
	) WITH  FILLFACTOR = 90  ON [PRIMARY] 
GO

 CREATE  UNIQUE  INDEX [AK2PA42601] ON [dbo].[PA42601]([PABILLFORMNAME]) WITH  FILLFACTOR = 90 ON [PRIMARY]
GO

 CREATE  UNIQUE  INDEX [AK3PA42601] ON [dbo].[PA42601]([PABillDesc]) WITH  FILLFACTOR = 90 ON [PRIMARY]
GO

 CREATE  UNIQUE  INDEX [AK2PA42801] ON [dbo].[PA42801]([PABILLCYCLEID], [CUSTCLAS]) WITH  FILLFACTOR = 90 ON [PRIMARY]
GO

 CREATE  UNIQUE  INDEX [AK2PA42802] ON [dbo].[PA42802]([PABILLCYCLEID1], [CUSTCLAS]) WITH  FILLFACTOR = 90 ON [PRIMARY]
GO

ALTER TABLE [dbo].[PA42901] ADD 
	CONSTRAINT [PKPA42901] PRIMARY KEY  NONCLUSTERED 
	(
		[PACTID],
		[PABILLCYCLEID]
	) WITH  FILLFACTOR = 90  ON [PRIMARY] 
GO

 CREATE  UNIQUE  INDEX [AK2PA42901] ON [dbo].[PA42901]([PABILLCYCLEID], [PACTID]) WITH  FILLFACTOR = 90 ON [PRIMARY]
GO

 CREATE  UNIQUE  INDEX [AK2PA42902] ON [dbo].[PA42902]([PABILLCYCLEID1], [PACTID]) WITH  FILLFACTOR = 90 ON [PRIMARY]
GO

ALTER TABLE [dbo].[PA43001] ADD 
	CONSTRAINT [PKPA43001] PRIMARY KEY  NONCLUSTERED 
	(
		[PAsfid],
		[PArecordid],
		[PAcosttrxid],
		[PAaccttype]
	) WITH  FILLFACTOR = 90  ON [PRIMARY] 
GO

ALTER TABLE [dbo].[PA43002] ADD 
	CONSTRAINT [PKPA43002] PRIMARY KEY  NONCLUSTERED 
	(
		[PAsfid],
		[PArecordid],
		[PAcosttrxid],
		[PAaccttype]
	) WITH  FILLFACTOR = 90  ON [PRIMARY] 
GO

ALTER TABLE [dbo].[PA43101] ADD 
	CONSTRAINT [PKPA43101] PRIMARY KEY  NONCLUSTERED 
	(
		[PA_Bill_Format_Number]
	) WITH  FILLFACTOR = 90  ON [PRIMARY] 
GO

 CREATE  UNIQUE  INDEX [AK2PA43101] ON [dbo].[PA43101]([PABILLFORMNAME]) WITH  FILLFACTOR = 90 ON [PRIMARY]
GO

 CREATE  UNIQUE  INDEX [AK3PA43101] ON [dbo].[PA43101]([PAcbdefault], [PA_Bill_Format_Number]) WITH  FILLFACTOR = 90 ON [PRIMARY]
GO

ALTER TABLE [dbo].[PA43102] ADD 
	CONSTRAINT [PKPA43102] PRIMARY KEY  NONCLUSTERED 
	(
		[PA_Bill_Format_Number],
		[SEQNUMBR]
	) WITH  FILLFACTOR = 90  ON [PRIMARY] 
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

setuser
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA41901].[PA_Update_Periodic_Opt]'
GO

EXEC sp_bindefault N'[dbo].[GPS_DATE]', N'[PA41901].[PA1stdatereportperiod]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA41901].[PAallow_1]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA41901].[PAallow_10]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA41901].[PAallow_11]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA41901].[PAallow_12]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA41901].[PAallow_13]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA41901].[PAallow_2]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA41901].[PAallow_3]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA41901].[PAallow_4]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA41901].[PAallow_5]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA41901].[PAallow_6]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA41901].[PAallow_7]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA41901].[PAallow_8]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA41901].[PAallow_9]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA41901].[PAdescriptionfrom]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA41901].[PAdexcriptionoptions_1]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA41901].[PAdexcriptionoptions_10]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA41901].[PAdexcriptionoptions_11]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA41901].[PAdexcriptionoptions_12]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA41901].[PAdexcriptionoptions_13]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA41901].[PAdexcriptionoptions_2]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA41901].[PAdexcriptionoptions_3]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA41901].[PAdexcriptionoptions_4]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA41901].[PAdexcriptionoptions_5]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA41901].[PAdexcriptionoptions_6]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA41901].[PAdexcriptionoptions_7]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA41901].[PAdexcriptionoptions_8]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA41901].[PAdexcriptionoptions_9]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA41901].[PAELcostdesc]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA41901].[PAELprofittypefrom]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA41901].[PAEQdoccounter]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA41901].[PAEQLdefinedprompt1]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA41901].[PAEQLdefinedprompt2]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA41901].[PAEQLunitcostfrom]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA41901].[PAnumofreportingperiods]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA41901].[PApasswordoptions_1]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA41901].[PApasswordoptions_10]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA41901].[PApasswordoptions_11]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA41901].[PApasswordoptions_12]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA41901].[PApasswordoptions_13]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA41901].[PApasswordoptions_2]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA41901].[PApasswordoptions_3]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA41901].[PApasswordoptions_4]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA41901].[PApasswordoptions_5]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA41901].[PApasswordoptions_6]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA41901].[PApasswordoptions_7]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA41901].[PApasswordoptions_8]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA41901].[PApasswordoptions_9]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA41901].[PAreportingperiods]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA41901].[PAsetupkey]'
GO

setuser
GO

setuser
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42001].[PA_Update_Periodic_Opt]'
GO

EXEC sp_bindefault N'[dbo].[GPS_DATE]', N'[PA42001].[PA1stdatereportperiod]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42001].[PAallow_1]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42001].[PAallow_10]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42001].[PAallow_11]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42001].[PAallow_12]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42001].[PAallow_13]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42001].[PAallow_2]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42001].[PAallow_3]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42001].[PAallow_4]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42001].[PAallow_5]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42001].[PAallow_6]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42001].[PAallow_7]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42001].[PAallow_8]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42001].[PAallow_9]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42001].[PAcostdesceML]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42001].[PAdescriptionfrom]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42001].[PAdexcriptionoptions_1]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42001].[PAdexcriptionoptions_10]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42001].[PAdexcriptionoptions_11]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42001].[PAdexcriptionoptions_12]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42001].[PAdexcriptionoptions_13]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42001].[PAdexcriptionoptions_2]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42001].[PAdexcriptionoptions_3]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42001].[PAdexcriptionoptions_4]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42001].[PAdexcriptionoptions_5]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42001].[PAdexcriptionoptions_6]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42001].[PAdexcriptionoptions_7]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42001].[PAdexcriptionoptions_8]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42001].[PAdexcriptionoptions_9]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42001].[PAMISCLdoccounter]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42001].[PAMLdefinedprompt1]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42001].[PAMLdefinedprompt2]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42001].[PAMLprofittypefrom]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42001].[PAMLunitcostfrom]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42001].[PAnumofreportingperiods]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42001].[PApasswordoptions_1]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42001].[PApasswordoptions_10]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42001].[PApasswordoptions_11]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42001].[PApasswordoptions_12]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42001].[PApasswordoptions_13]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42001].[PApasswordoptions_2]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42001].[PApasswordoptions_3]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42001].[PApasswordoptions_4]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42001].[PApasswordoptions_5]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42001].[PApasswordoptions_6]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42001].[PApasswordoptions_7]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42001].[PApasswordoptions_8]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42001].[PApasswordoptions_9]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42001].[PAreportingperiods]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42001].[PAsetupkey]'
GO

setuser
GO

setuser
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42201].[PA_Update_Periodic_Opt]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42201].[PAallow_1]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42201].[PAallow_10]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42201].[PAallow_11]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42201].[PAallow_12]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42201].[PAallow_13]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42201].[PAallow_2]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42201].[PAallow_3]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42201].[PAallow_4]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42201].[PAallow_5]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42201].[PAallow_6]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42201].[PAallow_7]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42201].[PAallow_8]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42201].[PAallow_9]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42201].[PAAllowPOWOPrinting]'
GO

EXEC sp_bindefault N'[dbo].[GPS_MONEY]', N'[PA42201].[PAbillnoteidx]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42201].[PAcostdescvi]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42201].[PAdeftopoubitcosts]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42201].[PAdescriptionfrom]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42201].[PAdexcriptionoptions_1]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42201].[PAdexcriptionoptions_10]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42201].[PAdexcriptionoptions_11]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42201].[PAdexcriptionoptions_12]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42201].[PAdexcriptionoptions_13]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42201].[PAdexcriptionoptions_2]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42201].[PAdexcriptionoptions_3]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42201].[PAdexcriptionoptions_4]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42201].[PAdexcriptionoptions_5]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42201].[PAdexcriptionoptions_6]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42201].[PAdexcriptionoptions_7]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42201].[PAdexcriptionoptions_8]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42201].[PAdexcriptionoptions_9]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42201].[PApasswordoptions_1]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42201].[PApasswordoptions_10]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42201].[PApasswordoptions_11]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42201].[PApasswordoptions_12]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42201].[PApasswordoptions_13]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42201].[PApasswordoptions_2]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42201].[PApasswordoptions_3]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42201].[PApasswordoptions_4]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42201].[PApasswordoptions_5]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42201].[PApasswordoptions_6]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42201].[PApasswordoptions_7]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42201].[PApasswordoptions_8]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42201].[PApasswordoptions_9]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42201].[PApodeformatouse]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42201].[PApoformatlabel1]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42201].[PApoformatlabel2]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42201].[PApoformatlabel3]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42201].[PApostoDynPM]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42201].[PApounitostfrom]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42201].[PAprcntvarianceallowed]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42201].[PAPriceLevelFromIV]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42201].[PAsetupkey]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42201].[PAvidefinedprompt1]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42201].[PAvidefinedprompt2]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42201].[PAviprofittypefrom]'
GO

setuser
GO

setuser
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42401].[FRTSCHID]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42401].[MSCSCHID]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42401].[PA_Update_Periodic_Opt]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42401].[PAallow_1]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42401].[PAallow_10]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42401].[PAallow_11]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42401].[PAallow_12]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42401].[PAallow_13]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42401].[PAallow_2]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42401].[PAallow_3]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42401].[PAallow_4]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42401].[PAallow_5]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42401].[PAallow_6]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42401].[PAallow_7]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42401].[PAallow_8]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42401].[PAallow_9]'
GO

EXEC sp_bindefault N'[dbo].[GPS_MONEY]', N'[PA42401].[PAbillnoteidx]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42401].[PAcostdescer]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42401].[PAdescriptionfrom]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42401].[PAeeprofittypefrom]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42401].[PAerdefinedprompt1]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42401].[PAerdefinedprompt2]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42401].[PAerdoccounter]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42401].[PAExpenseType]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42401].[PAFreight_Taxable_P]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42401].[PAMisc_Taxable_P]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42401].[PApasswordoptions_1]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42401].[PApasswordoptions_10]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42401].[PApasswordoptions_11]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42401].[PApasswordoptions_12]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42401].[PApasswordoptions_13]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42401].[PApasswordoptions_2]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42401].[PApasswordoptions_3]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42401].[PApasswordoptions_4]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42401].[PApasswordoptions_5]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42401].[PApasswordoptions_6]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42401].[PApasswordoptions_7]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42401].[PApasswordoptions_8]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42401].[PApasswordoptions_9]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42401].[PAPaymentMethod]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42401].[PApostoDynPM]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42401].[PAsetupkey]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42401].[PAVIDROAer]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42401].[TAXSCHID]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42401].[USEADVTX]'
GO

setuser
GO

setuser
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42501].[FRGTTXBL]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42501].[FRTSCHID]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42501].[MISCTXBL]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42501].[MSCSCHID]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42501].[NONIVSCH]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42501].[NONIVTXB]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42501].[PA_Billing_Discount_From]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42501].[PA_Calc_Retainer_Comm]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42501].[PA_Currency_To_Use]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42501].[PA_Default_Cutoff_Date]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42501].[PA_Include_Billed_Fees]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42501].[PA_Not_Allow_Qty_Writeup]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42501].[PA_Prorate_Cost]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42501].[PA_Retainer_Taxable]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42501].[PA_Update_Periodic_Opt]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42501].[PAallow_1]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42501].[PAallow_10]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42501].[PAallow_11]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42501].[PAallow_12]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42501].[PAallow_13]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42501].[PAallow_2]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42501].[PAallow_3]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42501].[PAallow_4]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42501].[PAallow_5]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42501].[PAallow_6]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42501].[PAallow_7]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42501].[PAallow_8]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42501].[PAallow_9]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42501].[PAbillerdefinedprompt1]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42501].[PAbillerdefinedprompt2]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42501].[PAbillidocounter]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42501].[PAdexcriptionoptions_1]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42501].[PAdexcriptionoptions_10]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42501].[PAdexcriptionoptions_11]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42501].[PAdexcriptionoptions_12]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42501].[PAdexcriptionoptions_13]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42501].[PAdexcriptionoptions_2]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42501].[PAdexcriptionoptions_3]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42501].[PAdexcriptionoptions_4]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42501].[PAdexcriptionoptions_5]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42501].[PAdexcriptionoptions_6]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42501].[PAdexcriptionoptions_7]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42501].[PAdexcriptionoptions_8]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42501].[PAdexcriptionoptions_9]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42501].[PALog_File]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42501].[PANotAllowQtyWritedown]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42501].[PApasswordoptions_1]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42501].[PApasswordoptions_10]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42501].[PApasswordoptions_11]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42501].[PApasswordoptions_12]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42501].[PApasswordoptions_13]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42501].[PApasswordoptions_2]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42501].[PApasswordoptions_3]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42501].[PApasswordoptions_4]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42501].[PApasswordoptions_5]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42501].[PApasswordoptions_6]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42501].[PApasswordoptions_7]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42501].[PApasswordoptions_8]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42501].[PApasswordoptions_9]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42501].[PAPostoDynRM]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42501].[PARevenue_Doc_Counter]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42501].[PARGApplyTo]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42501].[PAsetupkey]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42501].[TAXSCHID]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42501].[USEADVTX]'
GO

setuser
GO

setuser
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42601].[PA_Contract_Collating]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42601].[PA_Contract_Stick_Pin]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42601].[PA_Fees_Stick_Pin]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42601].[PA_Project_Collating]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42601].[PA_Project_Stick_Pin]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42601].[PA_Trxs_Stick_Pin]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42601].[PABill_Format_Key]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42601].[PABillDesc]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42601].[PABILLFORMNAME]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42601].[PAFeesDisplayOptions]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42601].[PAIFDataPrinted]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42601].[PALongFeeNameProject]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42601].[PALongFeeNameRetainer]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42601].[PALongFeeNameRetentions]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42601].[PALongFeeNameService]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42601].[PALongTrxNameEE]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42601].[PALongTrxNameEL]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42601].[PALongTrxNameIV]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42601].[PALongTrxNameML]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42601].[PALongTrxNameTS]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42601].[PALongTrxNameVI]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42601].[PAPrintBillNotesFee]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42601].[PAPrintSummaryCPFPEE]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42601].[PAPrintSummaryCPFPEL]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42601].[PAPrintSummaryCPFPIV]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42601].[PAPrintSummaryCPFPML]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42601].[PAPrintSummaryCPFPTS]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42601].[PAPrintSummaryCPFPVI]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42601].[PAprntbillnotesee1]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42601].[PAprntbillnotesEL]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42601].[PAprntbillnotesIV]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42601].[PAprntbillnotesML]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42601].[PAprntbillnotests1]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42601].[PAprntbillnotesvi1]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42601].[PAprntcontheading1]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42601].[PAprntcontrxbillnotes1]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42601].[PAprntprojheadings1]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42601].[PAprntprojtrxbillnotes1]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42601].[PAPRNTSORTEE]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42601].[PAPRNTSORTEL]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42601].[PAPRNTSORTIV]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42601].[PAPRNTSORTML]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42601].[PAPRNTSORTTS]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42601].[PAPRNTSORTVI]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42601].[PAPRNTSUMMEE]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42601].[PAPRNTSUMMEL]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42601].[PAPRNTSUMMIV]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42601].[PAPRNTSUMMML]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42601].[PAPRNTSUMMTS]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42601].[PAPRNTSUMMVI]'
GO

setuser
GO

setuser
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42602].[PABill_Format_Key]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42602].[USERID]'
GO

setuser
GO

setuser
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42701].[LOCNCODE]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42701].[PAallow_1]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42701].[PAallow_10]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42701].[PAallow_11]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42701].[PAallow_12]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42701].[PAallow_13]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42701].[PAallow_2]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42701].[PAallow_3]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42701].[PAallow_4]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42701].[PAallow_5]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42701].[PAallow_6]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42701].[PAallow_7]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42701].[PAallow_8]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42701].[PAallow_9]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42701].[PACBNOTRNSFRBILLNTS]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42701].[PACostDescriptionIV]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42701].[PAdescriptionfrom]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42701].[PAdexcriptionoptions_1]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42701].[PAdexcriptionoptions_10]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42701].[PAdexcriptionoptions_11]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42701].[PAdexcriptionoptions_12]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42701].[PAdexcriptionoptions_13]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42701].[PAdexcriptionoptions_2]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42701].[PAdexcriptionoptions_3]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42701].[PAdexcriptionoptions_4]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42701].[PAdexcriptionoptions_5]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42701].[PAdexcriptionoptions_6]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42701].[PAdexcriptionoptions_7]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42701].[PAdexcriptionoptions_8]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42701].[PAdexcriptionoptions_9]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42701].[PADONOTALLIV]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42701].[PAInventory_Counter]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42701].[PApasswordoptions_1]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42701].[PApasswordoptions_10]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42701].[PApasswordoptions_11]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42701].[PApasswordoptions_12]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42701].[PApasswordoptions_13]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42701].[PApasswordoptions_2]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42701].[PApasswordoptions_3]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42701].[PApasswordoptions_4]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42701].[PApasswordoptions_5]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42701].[PApasswordoptions_6]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42701].[PApasswordoptions_7]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42701].[PApasswordoptions_8]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42701].[PApasswordoptions_9]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42701].[PAPriceLevelFromIV]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42701].[PAsetupkey]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42701].[PAUserDefinedPrompt1IV]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42701].[PAUserDefinedPrompt2IV]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA42701].[TRKVDTRX]'
GO

setuser
GO

setuser
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42801].[CUSTCLAS]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42801].[PABILLCYCLEID]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42801].[PABILLFORMAT]'
GO

setuser
GO

setuser
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42802].[CUSTCLAS]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42802].[PABILLCYCLEID1]'
GO

setuser
GO

setuser
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42901].[PABILLCYCLEID]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42901].[PABILLFORMAT]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42901].[PACTID]'
GO

setuser
GO

setuser
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42902].[PABILLCYCLEID1]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA42902].[PACTID]'
GO

setuser
GO

setuser
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA43001].[PAaccttype]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA43001].[PAACTINDX]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA43001].[PAcosttrxid]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA43001].[PArecordid]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA43001].[PAsfid]'
GO

setuser
GO

setuser
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA43002].[PAaccttype]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA43002].[PAACTINDX]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA43002].[PAcosttrxid]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA43002].[PArecordid]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA43002].[PAsfid]'
GO

setuser
GO

setuser
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA43101].[PA_Bill_Format_Number]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA43101].[PABILLFORMNAME]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA43101].[PAcbdefault]'
GO

setuser
GO

setuser
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA43102].[PA_Bill_Format_Number]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA43102].[PABill_Format_Key]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA43102].[SEQNUMBR]'
GO

setuser
GO

