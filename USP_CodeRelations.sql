CREATE PROCEDURE USP_CodeRelations
		@CodeRelationId		int,
		@RelationType		Char(2),
		@ParentCode			Varchar(20),
		@ChildCode			Varchar(20),
		@Category			Varchar(20),
		@SubCategory		Varchar(30),
		@Location			Varchar(15),
		@TimeStamp			Datetime,
		@DeletedOn			Datetime
AS
IF EXISTS(SELECT CodeRelationId FROM [dbo].[CodeRelations] WHERE CodeRelationId = @CodeRelationId)
BEGIN
	UPDATE	[dbo].[CodeRelations]

END
ELSE
BEGIN
	INSERT INTO [dbo].[CodeRelations]
           ([CodeRelationId]
		   ,[RelationType]
           ,[ParentCode]
           ,[ChildCode]
           ,[Category]
           ,[SubCategory]
           ,[Location]
           ,[TimeStamp]
           ,[DeletedOn])
     VALUES
           (@CodeRelationId
		   ,@RelationType
           ,@ParentCode
           ,@ChildCode
           ,@Category
           ,@SubCategory
           ,@Location
           ,@TimeStamp
           ,@DeletedOn)
END