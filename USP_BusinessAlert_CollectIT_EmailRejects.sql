CREATE PROCEDURE USP_BusinessAlert_CollectIT_EmailRejects
AS
SET NOCOUNT ON

DECLARE	@Body					Varchar(MAX) = '',
		@EmailTo				Varchar(250) = 'bclayton@imccompanies.com;kpowell@imccompanies.com;',
		@EmailCC				Varchar(250) = 'cflores@imcc.com;',
		@EmailSubject			Varchar(75) = 'CollectIT - Email Rejects for ' + CONVERT(Varchar(10), DATEADD(day, DATEDIFF(day, 1, GETDATE()), 0), 101),
		@xml					Varchar(MAX)

SELECT	e.EnterpriseName,  
		c.CompanyName,  
		u.UserName, 
		u.Email, 
		t.Name, 
		l.letterID, 
		l.WasSent, 
		l.Date, 
		ISNULL(l.subject,'') AS subject, 
		cc.FirstName, 
		cc.LastName, 
		cc.Email AS CCEmail, 
		cc.IsActive, 
		cc.IsPrimary
INTO	#Temp
FROM	CollectIT.dbo.cs_letter l 
		JOIN CollectIT.dbo.cs_letterContact lc ON l.letterid=lc.letterid 
		JOIN CollectIT.dbo.cs_customercontact cc ON cc.customercontactid = lc.customercontactid 
		JOIN CollectIT.dbo.CS_customer C ON c.customerid = l.customerid 
		JOIN CollectIT.dbo.cs_Enterprise e ON e.enterpriseid=c.enterpriseid 
		JOIN CollectIT.dbo.cs_USer U ON u.userID=l.userid
		JOIN CollectIT.dbo.CS_LetterType t ON t.LetterTypeId=l.LetterType
WHERE	wassent = 0 
		AND l.Date >= DATEADD(day, DATEDIFF(day, 1, GETDATE()), 0)
        AND l.Date < DATEADD(day, DATEDIFF(day, 0, GETDATE()), 0)

SET @xml = CAST((SELECT [EnterpriseName] AS 'td','',[CompanyName] AS 'td','',
       [UserName] AS 'td','', [Email] AS 'td','', [Name] AS 'td','', [LetterID] AS 'td',
	   '', [WasSent] AS 'td','', [Date] AS 'td', '', [Subject] AS 'td', '', [FirstName] AS 'td',
	   '', [LastName] AS 'td', '', [CCEmail] AS 'td', '', [IsActive] AS 'td', '', [IsPrimary] AS 'td'
FROM  #Temp ORDER BY [EnterpriseName]
FOR XML PATH('tr'), ELEMENTS ) AS NVARCHAR(MAX))

SET @Body ='<html><body><H3>Email Rejections</H3>
<table border = 1> 
<tr>
<th> Enterprise Name </th> 
<th> Company Name </th> 
<th> User Name </th> 
<th> Email </th>
<th> Name </th> 
<th> Letter Id </th> 
<th> Was Sent </th> 
<th> Date </th>
<th> Subject </th> 
<th> First Name </th> 
<th> Last Name </th> 
<th> CC Email </th>
<th> Is Active </th> 
<th> Is Primary </th>
</tr>'    

SET @Body = @Body + @xml +'</table></body></html>'

EXEC msdb.dbo.sp_send_dbmail @profile_name = 'Great Plains Notifications',  
			@recipients = @EmailTo,
			@copy_recipients = @EmailCC,
			@subject = @EmailSubject,
			@body_format = 'HTML',
			@body = @Body

DROP TABLE #Temp