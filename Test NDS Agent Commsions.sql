/****** Script for SelectTopNRows command from SSMS  ******/
SELECT *
FROM [GPCustom].[dbo].[AgentsSettlementsCommisions]
where BatchId = 'NDS20180915'

/*
update	AgentsSettlementsCommisions
set		SubmitForApproval = 1,
		ReportsCreated = 1
where	BatchId = 'NDS20180915'
		and Agent = '10'

$("#<%=butRunReports.ClientID%>").show();
	        $("#<%=butSendApprovals.ClientID%>").show();
	        $("#<%=butSendToGP.ClientID%>").hide();
*/