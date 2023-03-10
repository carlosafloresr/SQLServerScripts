if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PA01901]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[PA01901]
GO

CREATE TABLE [dbo].[PA01901] (
	[PATranType] [smallint] NOT NULL ,
	[DOCNUMBR] [char] (21) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[CUSTNMBR] [char] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PADOCDT] [datetime] NOT NULL ,
	[PACOSTOWNER] [char] (31) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[RMDTYPAL] [smallint] NOT NULL ,
	[PABILLTRXT] [smallint] NOT NULL ,
	[PADocnumber20] [char] (17) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[DCSTATUS] [smallint] NOT NULL ,
	[DEX_ROW_ID] [int] IDENTITY (1, 1) NOT NULL 
) ON [PRIMARY]
GO

setuser
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA01901].[CUSTNMBR]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA01901].[DCSTATUS]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA01901].[DOCNUMBR]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA01901].[PABILLTRXT]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA01901].[PACOSTOWNER]'
GO

EXEC sp_bindefault N'[dbo].[GPS_DATE]', N'[PA01901].[PADOCDT]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[PA01901].[PADocnumber20]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA01901].[PATranType]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[PA01901].[RMDTYPAL]'
GO

setuser
GO

