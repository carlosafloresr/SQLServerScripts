CREATE PROCEDURE USP_DocumentRoute
		@DocumentID			int,
		@UserID				int = Null,
		@ByUserID			int = Null,
		@Comment			text = Null,
		@Status				int = Null,
		@Completed			smalldatetime = Null,
		@DueDate			smalldatetime = Null,
		@RouteStepID		int = Null,
		@CallingDocRouteID	int = Null,
		@SiblingDocRouteID	int = Null,
		@ParentDocRouteID	int = Null,
		@OriginatorID		int = Null,
		@StartDate			smalldatetime = Null,
		@Finished			int = Null,
		@RouteWait			int = Null,
		@Direction			int = Null,
		@ProcessFlag		int = Null,
		@ProcessDate		smalldatetime = Null,
		@ItemType			int = Null,
		@RouteType			int = Null
AS
INSERT INTO dbo.DocumentRoute
           (DocumentID
           ,UserID
           ,ByUserID
           ,Comment
           ,Status
           ,Completed
           ,DueDate
           ,RouteStepID
           ,CallingDocRouteID
           ,SiblingDocRouteID
           ,ParentDocRouteID
           ,OriginatorID
           ,StartDate
           ,Finished
           ,RouteWait
           ,Direction
           ,ProcessFlag
           ,ProcessDate
           ,ItemType
           ,RouteType)
     VALUES
           (@DocumentID
           ,@UserID
           ,@ByUserID
           ,@Comment
           ,@Status
           ,@Completed
           ,@DueDate
           ,@RouteStepID
           ,@CallingDocRouteID
           ,@SiblingDocRouteID
           ,@ParentDocRouteID
           ,@OriginatorID
           ,@StartDate
           ,@Finished
           ,@RouteWait
           ,@Direction
           ,@ProcessFlag
           ,@ProcessDate
           ,@ItemType
           ,@RouteType)
GO


