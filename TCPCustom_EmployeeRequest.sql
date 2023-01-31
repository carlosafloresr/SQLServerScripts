-- SELECT * FROM TimeClockPlus.dbo.EmployeeRequests

SELECT	Company,
		EmployeeId,
		Request,
		UTCDateAdded,
		MIN(RequestDate) AS RequestDateMin,
		MAX(RequestDate) AS RequestDateMax,
		MAX(RecordId) AS RecordId,
		CAST(0 AS Bit) AS Notified
FROM	TimeClockPlus.dbo.EmployeeRequests
GROUP BY
		Company,
		EmployeeId,
		Request,
		UTCDateAdded

TRUNCATE TABLE EmployeeRequest

/*
CREATE PROCEDURE USP_EmployeeRequest
AS
INSERT INTO TCPCustom.dbo.EmployeeRequest
	   (Company,
		EmployeeId,
		Request,
		UTCDateAdded,
		RequestDateMin,
		RequestDateMax,
		RecordId,
		Notified)
SELECT	TCP.Company,
		TCP.EmployeeId,
		TCP.Request,
		TCP.UTCDateAdded,
		TCP.RequestDateMin,
		TCP.RequestDateMax,
		TCP.RecordId,
		TCP.Notified
FROM   (SELECT	Company,
		EmployeeId,
		Request,
		UTCDateAdded,
		MIN(RequestDate) AS RequestDateMin,
		MAX(RequestDate) AS RequestDateMax,
		MAX(RecordId) AS RecordId,
		CAST(0 AS Bit) AS Notified
FROM	TimeClockPlus.dbo.EmployeeRequests
GROUP BY
		Company,
		EmployeeId,
		Request,
		UTCDateAdded) TCP
WHERE	TCP.RecordId NOT IN (SELECT RecordId FROM TCPCustom.dbo.EmployeeRequest)

EXECUTE USP_EmployeeRequest
*/

CREATE VIEW View_EmployeeRequest
AS
SELECT	VE.Company,
		CompanyName,
		VE.EmployeeId,
		EmployeeCode,
		FirstName,
		LastName,
		Address1,
		City,
		State,
		Zip,
		HomePhone,
		BirthDate,
		DateHire,
		Sex,
		Department,
		ManagerUID,
		UserId,
		ManagerName,
		Email,
		Request,
		UTCDateAdded,
		RequestDateMin,
		RequestDateMax,
		RecordId
FROM	View_Employees VE
		INNER JOIN EmployeeRequest ER ON VE.EmployeeId = ER.EmployeeId AND VE.Company = ER.Company AND ER.Notified = 0