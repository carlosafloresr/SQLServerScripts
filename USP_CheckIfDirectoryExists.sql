USE [GPCustom]
GO
/****** Object:  UserDefinedFunction [dbo].[CheckIfFileExists]    Script Date: 7/19/2022 8:59:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[USP_CheckIfDirectoryExists]
	@Path		Varchar(400),
	@DoesExists	Bit OUTPUT
AS
SET NOCOUNT ON

DECLARE @xp_fileexist_output Table (
	[FILE_EXISTS]				int	not null,
	[FILE_IS_DIRECTORY]			int	not null,
	[PARENT_DIRECTORY_EXISTS]	int	not null)

INSERT INTO @xp_fileexist_output
EXECUTE master.dbo.xp_fileexist @path

SET @DoesExists = CAST((SELECT [FILE_IS_DIRECTORY] FROM @xp_fileexist_output) AS Bit)