USE Integrations
GO

CREATE PROCEDURE USP_Integrations_Log
		@Integration	Varchar(5),
		@Company		varchar(5),
		@BatchId		varchar(25),
		@Activity		varchar(200),
		@Message		varchar(max) = Null,
		@Status			smallint
AS
INSERT INTO dbo.Integrations_Log
           (Integration
		   ,Company
           ,BatchId
           ,Activity
           ,Message
           ,Status)
     VALUES
           (@Integration
		   ,@Company
           ,@BatchId
           ,@Activity
           ,@Message
           ,@Status)
GO


