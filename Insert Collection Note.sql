DECLARE	@CUSTNMBR char(15), 
		@CPRCSTNM char(15), 
		@DATE1 datetime, 
		@Contact_Date datetime,
		@TIME1 datetime, 
		@Contact_Time datetime, 
		@NOTEINDX numeric(19,5), 
		@RevisionNumber smallint, 
		@CN_Group_Note tinyint, 
		@Caller_ID_String char(15), 
		@Action_Promised char(17), 
		@ActionType smallint, 
		@Action_Date datetime, 
		@Action_Assigned_To char(15), 
		@Action_Completed tinyint, 
		@ACTCMDSP tinyint, 
		@Action_Completed_Date datetime, 
		@Action_Completed_Time datetime, 
		@Amount_Promised numeric(19,5), 
		@Amount_Received numeric(19,5), 
		@USERID char(15), 
		@Note_Display_String char(71), 
		@CNTCPRSN char(61), 
		@ADRSCODE char(15),
		@USERDEF1 char(21), 
		@USERDEF2 char(21), 
		@USRDAT01 datetime, 
		@PRIORT smallint, 
		@NOTECAT char(15), 
		@NoteStatus smallint, 
		@Action_Cancelled_By char(15), 
		@Action_Cancelled_Date datetime, 
		@DEX_ROW_ID int
		
SET NOCOUNT ON
 
BEGIN 
	INSERT INTO .CN00100 
			(CUSTNMBR, 
			CPRCSTNM, 
			DATE1, 
			Contact_Date, 
			TIME1, 
			Contact_Time, 
			NOTEINDX, 
			RevisionNumber, 
			CN_Group_Note, 
			Caller_ID_String, 
			Action_Promised, 
			ActionType, 
			Action_Date, 
			Action_Assigned_To, 
			Action_Completed, 
			ACTCMDSP, 
			Action_Completed_Date, 
			Action_Completed_Time, 
			Amount_Promised, 
			Amount_Received, 
			USERID, 
			Note_Display_String, 
			CNTCPRSN, 
			ADRSCODE, 
			USERDEF1, 
			USERDEF2, 
			USRDAT01, 
			PRIORT, 
			NOTECAT, 
			NoteStatus, 
			Action_Cancelled_By, 
			Action_Cancelled_Date) 
	VALUES 
			(@CUSTNMBR, 
			@CPRCSTNM, 
			@DATE1, 
			@Contact_Date, 
			@TIME1, 
			@Contact_Time, 
			@NOTEINDX, 
			@RevisionNumber, 
			@CN_Group_Note, 
			@Caller_ID_String, 
			@Action_Promised, 
			@ActionType, 
			@Action_Date, 
			@Action_Assigned_To, 
			@Action_Completed, 
			@ACTCMDSP, 
			@Action_Completed_Date, 
			@Action_Completed_Time, 
			@Amount_Promised, 
			@Amount_Received, 
			@USERID, 
			@Note_Display_String, 
			@CNTCPRSN, 
			@ADRSCODE, 
			@USERDEF1, 
			@USERDEF2, 
			@USRDAT01, 
			@PRIORT, 
			@NOTECAT, 
			@NoteStatus, 
			@Action_Cancelled_By, 
			@Action_Cancelled_Date) 
					
	SELECT	@DEX_ROW_ID = @@IDENTITY 
END 

SET NOCOUNT OFF