-- FIXED ON 05/03/2021 AT 11:42 AM
SELECT	[EmployeeID]
		,UPPER([FirstName]) AS FirstName
		,UPPER([LastName]) AS LastName
		,[EmployeeNumber]
		,'001' AS ShopID
		,'' AS SSN
		,'' AS Address1
		,'' AS Address2
		,'' AS City
		,'' AS State
		,'' AS ZipCode
		,[WorkPhone]
		,'' AS OfficeExt
		,[HomePhone]
		,'' AS EmergencyPh
		,'' AS EmergencyContact
		,'' AS EmpClass
		,'' AS PayGrade
		,'' AS PrimShift
		,CASE WHEN EMP.[Inactive] = 1 THEN 'I' ELSE 'A' END AS [Status]
		,EMP.HireDate
FROM	[DirectorSeries].[dbo].[Employee] EMP
		INNER JOIN [DirectorSeries].[dbo].[Contact] CON ON EMP.ContactID = CON.ContactID
WHERE	EMP.[Inactive] <> 1