if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[IMC_CENSUSREP]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[IMC_CENSUSREP]
GO

CREATE TABLE [dbo].[IMC_CENSUSREP] (
	[RowNumber] [int] NULL ,
	[EMPLOYID] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[DEPRTMNT] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[DEPTDESC] [varchar] (31) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[LASTNAME] [varchar] (21) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[FNAMEMI] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[SOCSCNUM] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[HIREDATE] [datetime] NULL ,
	[GROSSPAY] [numeric](19, 5) NULL ,
	[GENDER] [smallint] NULL ,
	[CITY] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[STATE] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[LASTDAYWORKED_I] [datetime] NULL ,
	[BIRTHDATE] [datetime] NULL ,
	[MARITALSTATUS] [smallint] NULL ,
	[INACTIVE] [smallint] NULL ,
	[EMPLYTYPE] [smallint] NULL ,
	[WC_CODE] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[WC_RATE] [numeric](19, 10) NULL ,
	[WC_COST] [numeric](19, 5) NULL ,
	[JOBDESC] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[PAYCODE] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[PAYRATE] [numeric](19, 5) NULL ,
	[FLSA] [smallint] NULL ,
	[BENCODE] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[BENRATE] [numeric](19, 5) NULL ,
	[MONTHLY_BENEFIT] [numeric](19, 5) NULL ,
	[DEDNCODE] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[DEDNRATE] [numeric](19, 5) NULL ,
	[MONTHLY_DEDN] [numeric](19, 5) NULL ,
	[BEN_ACTIVATION_DATE] [datetime] NULL ,
	[BEN_TERM_DATE] [datetime] NULL ,
	[DEDN_ACTIVATION_DATE] [datetime] NULL ,
	[DEDN_TERM_DATE] [datetime] NULL ,
	[REPID] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[USERID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[PayrolCD] [char] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[UprTrxAm] [numeric](19, 5) NULL 
) ON [PRIMARY]
GO

