if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DB_Users]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[DB_Users]
GO

CREATE TABLE [dbo].[DB_Users] (
	[Domain] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[UserId] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[AccessAS] [bit] NOT NULL ,
	[AccessEU] [bit] NOT NULL ,
	[AccessNA] [bit] NOT NULL ,
	[AccessSA] [bit] NOT NULL 
) ON [PRIMARY]
GO

