USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_AdvanceApprovers]    Script Date: 2/25/2022 3:17:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[USP_AdvanceApprovers]
		@Company	Varchar(5),
		@Email		Varchar(50),
		@UserName	Varchar(30)
AS
INSERT INTO GPCustom.dbo.AdvanceApprovers
           (Company
           ,Email
           ,UserName)
VALUES
           (@Company
           ,@Email
           ,@UserName)

UPDATE	AdvanceApprovers
SET		UserName = DATA.Name
FROM	(
		SELECT	IUS.*, DOU.SN + ', ' + dou.GivenName AS Name
		FROM	AdvanceApprovers IUS
				INNER JOIN DomainUsers DOU ON LEFT(IUS.Email, dbo.AT('@', IUS.Email, 1) - 1) = DOU.userid
		) DATA
WHERE	AdvanceApprovers.RecordId = DATA.RecordId
		AND AdvanceApprovers.UserName <> DATA.Name