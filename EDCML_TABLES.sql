if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[EDCML001]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[EDCML001]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[EDCML002]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[EDCML002]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[EDCML003]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[EDCML003]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[EDCML004]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[EDCML004]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[EDCML005]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[EDCML005]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[EDCML006]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[EDCML006]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[EDCML007]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[EDCML007]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[EDCML008]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[EDCML008]
GO

CREATE TABLE [dbo].[EDCML001] (
	[CMPANYID] [smallint] NOT NULL ,
	[mlcEnableMLChecks] [tinyint] NOT NULL ,
	[USERID] [char] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[DATE1] [datetime] NOT NULL ,
	[DEX_ROW_ID] [int] IDENTITY (1, 1) NOT NULL 
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[EDCML002] (
	[CURNCYID] [char] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[CRNCYDSC] [char] (31) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[DEX_ROW_ID] [int] IDENTITY (1, 1) NOT NULL 
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[EDCML003] (
	[CURNCYID] [char] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[mlcLanguage] [smallint] NOT NULL ,
	[CURTEXT_1] [char] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[CURTEXT_2] [char] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[CURTEXT_3] [char] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[mlcLocalTermn] [char] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[DEX_ROW_ID] [int] IDENTITY (1, 1) NOT NULL 
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[EDCML004] (
	[CHEKBKID] [char] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[mlcLanguage] [smallint] NOT NULL ,
	[mlcEnableMLChecks] [tinyint] NOT NULL ,
	[mlcChkLyt] [smallint] NOT NULL ,
	[DEX_ROW_ID] [int] IDENTITY (1, 1) NOT NULL 
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[EDCML005] (
	[BACHNUMB] [char] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[mlcLanguage] [smallint] NOT NULL ,
	[mlcEnableMLChecks] [tinyint] NOT NULL ,
	[CHEKBKID] [char] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[CURNCYID] [char] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[DEX_ROW_ID] [int] IDENTITY (1, 1) NOT NULL 
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[EDCML006] (
	[CHEKNMBR] [char] (21) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[mlcLanguage] [smallint] NOT NULL ,
	[mlcEnableMLChecks] [tinyint] NOT NULL ,
	[CHAMCBID] [char] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[CHEKAMNT] [numeric](19, 5) NOT NULL ,
	[DEX_ROW_ID] [int] IDENTITY (1, 1) NOT NULL 
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[EDCML007] (
	[VENDORID] [char] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[VADCDTRO] [char] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[mlcLanguage] [smallint] NOT NULL ,
	[mlcEnableMLChecks] [tinyint] NOT NULL ,
	[DEX_ROW_ID] [int] IDENTITY (1, 1) NOT NULL 
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[EDCML008] (
	[CMPANYID] [smallint] NOT NULL ,
	[mlcLanguage] [smallint] NOT NULL ,
	[mlcChkLyt] [smallint] NOT NULL ,
	[mlcChkDtSeparator] [smallint] NOT NULL ,
	[mlcChkDtFmt] [smallint] NOT NULL ,
	[DEX_ROW_ID] [int] IDENTITY (1, 1) NOT NULL 
) ON [PRIMARY]
GO

setuser
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[EDCML001].[CMPANYID]'
GO

EXEC sp_bindefault N'[dbo].[GPS_DATE]', N'[EDCML001].[DATE1]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[EDCML001].[mlcEnableMLChecks]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[EDCML001].[USERID]'
GO

setuser
GO

setuser
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[EDCML002].[CRNCYDSC]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[EDCML002].[CURNCYID]'
GO

setuser
GO

setuser
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[EDCML003].[CURNCYID]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[EDCML003].[CURTEXT_1]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[EDCML003].[CURTEXT_2]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[EDCML003].[CURTEXT_3]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[EDCML003].[mlcLanguage]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[EDCML003].[mlcLocalTermn]'
GO

setuser
GO

setuser
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[EDCML004].[CHEKBKID]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[EDCML004].[mlcChkLyt]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[EDCML004].[mlcEnableMLChecks]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[EDCML004].[mlcLanguage]'
GO

setuser
GO

setuser
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[EDCML005].[BACHNUMB]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[EDCML005].[CHEKBKID]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[EDCML005].[CURNCYID]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[EDCML005].[mlcEnableMLChecks]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[EDCML005].[mlcLanguage]'
GO

setuser
GO

setuser
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[EDCML006].[CHAMCBID]'
GO

EXEC sp_bindefault N'[dbo].[GPS_MONEY]', N'[EDCML006].[CHEKAMNT]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[EDCML006].[CHEKNMBR]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[EDCML006].[mlcEnableMLChecks]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[EDCML006].[mlcLanguage]'
GO

setuser
GO

setuser
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[EDCML007].[mlcEnableMLChecks]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[EDCML007].[mlcLanguage]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[EDCML007].[VADCDTRO]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[EDCML007].[VENDORID]'
GO

setuser
GO

setuser
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[EDCML008].[CMPANYID]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[EDCML008].[mlcChkDtFmt]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[EDCML008].[mlcChkDtSeparator]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[EDCML008].[mlcChkLyt]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[EDCML008].[mlcLanguage]'
GO

setuser
GO

