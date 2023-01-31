USE [GIS]
GO

TRUNCATE TABLE [dbo].[CN00100]
TRUNCATE TABLE [dbo].[CN00500]
TRUNCATE TABLE [dbo].[CN20100]
GO

INSERT INTO [dbo].[CN00100]
           ([CUSTNMBR]
           ,[CPRCSTNM]
           ,[DATE1]
           ,[Contact_Date]
           ,[TIME1]
           ,[Contact_Time]
           ,[NOTEINDX]
           ,[RevisionNumber]
           ,[CN_Group_Note]
           ,[Caller_ID_String]
           ,[Action_Promised]
           ,[ActionType]
           ,[Action_Date]
           ,[Action_Assigned_To]
           ,[Action_Completed]
           ,[ACTCMDSP]
           ,[Action_Completed_Date]
           ,[Action_Completed_Time]
           ,[Amount_Promised]
           ,[Amount_Received]
           ,[USERID]
           ,[Note_Display_String]
           ,[CNTCPRSN]
           ,[ADRSCODE]
           ,[USERDEF1]
           ,[USERDEF2]
           ,[USRDAT01]
           ,[PRIORT]
           ,[NOTECAT]
           ,[NoteStatus]
           ,[Action_Cancelled_By]
           ,[Action_Cancelled_Date]
           ,[MODIFDT]
           ,[CN_Pinned])
SELECT	[CUSTNMBR]
           ,[CPRCSTNM]
           ,[DATE1]
           ,[Contact_Date]
           ,[TIME1]
           ,[Contact_Time]
           ,[NOTEINDX]
           ,[RevisionNumber]
           ,[CN_Group_Note]
           ,[Caller_ID_String]
           ,[Action_Promised]
           ,[ActionType]
           ,[Action_Date]
           ,[Action_Assigned_To]
           ,[Action_Completed]
           ,[ACTCMDSP]
           ,[Action_Completed_Date]
           ,[Action_Completed_Time]
           ,[Amount_Promised]
           ,[Amount_Received]
           ,[USERID]
           ,[Note_Display_String]
           ,[CNTCPRSN]
           ,[ADRSCODE]
           ,[USERDEF1]
           ,[USERDEF2]
           ,[USRDAT01]
           ,[PRIORT]
           ,[NOTECAT]
           ,[NoteStatus]
           ,[Action_Cancelled_By]
           ,[Action_Cancelled_Date]
           ,[MODIFDT]
           ,[CN_Pinned]
FROM	[SECSQL01T].[GIS].[dbo].[CN00100]

INSERT INTO [dbo].[CN00500]
           ([CUSTNMBR]
           ,[CRDTMGR]
           ,[PreferredContactMethod]
           ,[NOMAIL]
           ,[ADRSCODE]
           ,[Time_Zone]
           ,[CN_Credit_Control_Cycle]
           ,[USRTAB01]
           ,[USRTAB09]
           ,[USERDEF1]
           ,[USERDEF2]
           ,[USRDAT01]
           ,[User_Defined_CB1]
           ,[User_Defined_CB2]
           ,[CollectionPlanID]
           ,[Action_Promised]
           ,[DOCNUMBR]
           ,[RMDTYPAL]
           ,[NOTEINDX]
           ,[TXTFIELD])
SELECT	[CUSTNMBR]
		,[CRDTMGR]
		,[PreferredContactMethod]
		,[NOMAIL]
		,[ADRSCODE]
		,[Time_Zone]
		,[CN_Credit_Control_Cycle]
		,[USRTAB01]
		,[USRTAB09]
		,[USERDEF1]
		,[USERDEF2]
		,[USRDAT01]
		,[User_Defined_CB1]
		,[User_Defined_CB2]
		,[CollectionPlanID]
		,[Action_Promised]
		,[DOCNUMBR]
		,[RMDTYPAL]
		,[NOTEINDX]
		,[TXTFIELD]
FROM	[SECSQL01T].[GIS].[dbo].[CN00500]

INSERT INTO [dbo].[CN20100]
           ([CUSTNMBR]
           ,[CPRCSTNM]
           ,[RMDTYPAL]
           ,[DOCNUMBR]
           ,[NOTEINDX]
           ,[ActionType]
           ,[ActionAmount]
           ,[CURTRXAM]
           ,[CURNCYID]
           ,[CURRNIDX]
           ,[AGNGBUKT]
           ,[DOCDATE])
SELECT	[CUSTNMBR]
           ,[CPRCSTNM]
           ,[RMDTYPAL]
           ,[DOCNUMBR]
           ,[NOTEINDX]
           ,[ActionType]
           ,[ActionAmount]
           ,[CURTRXAM]
           ,[CURNCYID]
           ,[CURRNIDX]
           ,[AGNGBUKT]
           ,[DOCDATE]
FROM	[SECSQL01T].[GIS].[dbo].[CN20100]
