USE [FRS]
GO

/****** Object:  View [dbo].[vwContacts]    Script Date: 3/5/2014 8:32:32 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
/*
SELECT * FROM vwContacts
*/
ALTER VIEW [dbo].[vwContacts]
AS
WITH 
Customers AS (
				SELECT	Data.RepairID, 
						dbo.Contacts.Name, 
						dbo.Contacts.Phone, 
						dbo.Contacts.Email
				FROM	dbo.Tickets AS Data 
						INNER JOIN lookup.ContactsToTickets AS mapContacts ON Data.ID = mapContacts.TicketID 
						INNER JOIN dbo.Contacts ON mapContacts.ContactID = dbo.Contacts.ID
				WHERE	dbo.Contacts.Type = 1
				), 
Dispatchers AS (	
				SELECT	Data.RepairID, 
						contacts_3.Name, 
						contacts_3.Phone, 
						contacts_3.Email
				FROM    dbo.Tickets AS Data 
						INNER JOIN lookup.ContactsToTickets AS mapContacts ON Data.ID = mapContacts.TicketID 
						INNER JOIN dbo.Contacts AS contacts_3 ON mapContacts.ContactID = contacts_3.ID
				WHERE	contacts_3.Type = 2
				), 
Drivers AS (
				SELECT	Data.RepairID, 
						contacts_2.Name, 
						contacts_2.Phone, 
						contacts_2.Email
				FROM	dbo.Tickets AS Data 
						INNER JOIN lookup.ContactsToTickets AS mapContacts ON Data.ID = mapContacts.TicketID 
						INNER JOIN dbo.Contacts AS contacts_2 ON mapContacts.ContactID = contacts_2.ID
				WHERE	contacts_2.Type = 3
			), 
TrkCmpys AS (
				SELECT	Data.RepairID, 
						contacts_1.Name, 
						contacts_1.Phone, 
						contacts_1.Email
				FROM	dbo.Tickets AS Data 
						INNER JOIN lookup.ContactsToTickets AS mapContacts ON Data.ID = mapContacts.TicketID 
						INNER JOIN dbo.Contacts AS contacts_1 ON mapContacts.ContactID = contacts_1.ID
				WHERE   contacts_1.Type = 5
			)

SELECT	dbo.Tickets.ID, 
		dbo.Tickets.RepairID, 
		Customers_1.Name AS CustomerName, 
		Customers_1.Phone AS CustomerPhone, 
        Customers_1.Email AS CustomerEmail, 
		Dispatchers_1.Name AS DispatcherName, 
		Dispatchers_1.Phone AS DispatcherPhone, 
        Dispatchers_1.Email AS DispatcherEmail, 
		Drivers_1.Name AS DriverName, 
		Drivers_1.Phone AS DriverPhone, 
		Drivers_1.Email AS DriverEmail, 
        TrkCmpys_1.Name AS TrkCmpyName, 
		TrkCmpys_1.Phone AS TrkCmpyPhone, 
		TrkCmpys_1.Email AS TrkCmpyEmail
FROM	dbo.Tickets 
		LEFT OUTER JOIN Customers AS Customers_1 ON dbo.Tickets.RepairID = Customers_1.RepairID 
		LEFT OUTER JOIN Dispatchers AS Dispatchers_1 ON dbo.Tickets.RepairID = Dispatchers_1.RepairID 
		LEFT OUTER JOIN Drivers AS Drivers_1 ON dbo.Tickets.RepairID = Drivers_1.RepairID 
		LEFT OUTER JOIN TrkCmpys AS TrkCmpys_1 ON dbo.Tickets.RepairID = TrkCmpys_1.RepairID

GO


