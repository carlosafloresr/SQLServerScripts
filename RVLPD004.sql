if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[RVLPD004]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[RVLPD004]
GO

CREATE TABLE [dbo].[RVLPD004] (
	[CUSTNMBR] [char] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[STMTNAME] [char] (65) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PMTDOCID] [char] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[DEX_ROW_ID] [int] IDENTITY (1, 1) NOT NULL 
) ON [PRIMARY]
GO

setuser
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[RVLPD004].[CUSTNMBR]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[RVLPD004].[PMTDOCID]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[RVLPD004].[STMTNAME]'
GO

setuser
GO

