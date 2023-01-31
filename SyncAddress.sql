USE [CollectIT]
GO

/****** Object:  StoredProcedure [dbo].[SyncAddress]    Script Date: 12/28/2016 3:00:11 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SyncAddress]
AS
BEGIN
    SET NOCOUNT ON;

    
    UPDATE sta
    SET sta.EnterpriseId = tbl.EnterpriseId
    FROM [Staging.CustomerAddress] sta
    JOIN CS_Enterprise tbl ON rtrim(isnull(tbl.EnterpriseNumber, '')) = isnull(sta.EnterpriseNumber, '')

    DELETE [Staging.CustomerAddress]
    WHERE EnterpriseId IS NULL

    UPDATE sta
    SET sta.CustomerId = tbl.CustomerId
    FROM [Staging.CustomerAddress] sta
    JOIN CS_Customer tbl ON rtrim(isnull(tbl.CustomerNumber, '')) = rtrim(isnull(sta.CustomerNumber, ''))
        AND tbl.EnterpriseId = sta.EnterpriseId

    DELETE [Staging.CustomerAddress]
    WHERE CustomerId IS NULL

    UPDATE sta
    SET sta.AddressId = addr.CustomerAddressId
    FROM [Staging.CustomerAddress] sta
    JOIN CS_CustomerAddress addr ON addr.CustomerId = sta.CustomerId
        AND rtrim(isnull(addr.ERPAddrId, '')) = rtrim(isnull(sta.ERPAddrId, ''))


    UPDATE sta
    SET sta.ContactId = con.CustomerContactId
    FROM [Staging.CustomerAddress] sta
    JOIN CS_CustomerContact con ON con.CustomerId = sta.CustomerId
        AND rtrim(isnull(con.FirstName, '') + ' ' + isnull(con.LastName, '')) = rtrim(isnull(sta.ContactPerson, ''))

    INSERT INTO [dbo].[CS_CustomerAddress] (
        [ERPAddrId]
        ,[CustomerId]
        ,[CustomerNum]
        ,[Address]
        ,[Address2]
        ,[State]
        ,[City]
        ,[Zip]
        ,[Country]
        ,[UpdateDateDate]
        ,[IsMain]
        ,[EnterpriseId]
        )
    SELECT ERPAddrId
        ,CustomerId
        ,CustomerNumber
        ,rtrim(isnull(MIN(Address1), ''))
        ,rtrim(isnull(MIN(Address2), '')) + ' ' + rtrim(isnull(MIN(Address3), ''))
        ,rtrim(isnull(MIN(STATE), ''))
        ,rtrim(isnull(MIN(City), ''))
        ,rtrim(isnull(MIN(ZipCode), ''))
        ,rtrim(isnull(MIN(Country), ''))
        ,Min(ModifiedAddress)
        ,0
        ,EnterpriseId
    FROM [Staging.CustomerAddress]
    WHERE AddressId IS NULL
    GROUP BY EnterpriseId
        ,CustomerId
        ,CustomerNumber
        ,ERPAddrId

    UPDATE addr
    SET addr.Address = rtrim(isnull(sta.Address1, ''))
        ,addr.Address2 = rtrim(isnull(sta.Address2, '')) + ' ' + rtrim(isnull(sta.Address3, ''))
        ,addr.City = rtrim(isnull(sta.City, ''))
        ,addr.STATE = rtrim(isnull(sta.STATE, ''))
        ,addr.Zip = rtrim(isnull(sta.ZipCode, ''))
        ,addr.Country = rtrim(isnull(sta.Country, ''))
        ,addr.UpdateDateDate = sta.ModifiedAddress
    FROM [Staging.CustomerAddress] sta
    JOIN CS_CustomerAddress addr ON sta.AddressId = addr.CustomerAddressId
    WHERE addr.UpdateDateDate < sta.ModifiedAddress


    UPDATE sta
    SET sta.AddressId = addr.CustomerAddressId
    FROM [Staging.CustomerAddress] sta
    JOIN CS_CustomerAddress addr ON addr.CustomerId = sta.CustomerId
        AND rtrim(isnull(addr.ERPAddrId, '')) = rtrim(isnull(sta.ERPAddrId, ''))

	DECLARE @ContactIds TABLE (
		ContactId Int
	)

    INSERT INTO [dbo].[CS_CustomerContact] (
        [FirstName]
        ,[LastName]
        ,[Email]
        ,[IsPrimary]
        ,[CustomerId]
        ,[AddressId]
        ,[IsActive]
        )
	OUTPUT inserted.CustomerContactId INTO @ContactIds
    SELECT rtrim(isnull(ContactPerson, ''))
        ,''
        ,rtrim(isnull(ContactEmail, ''))
        ,0
        ,CustomerId
        ,AddressId
        ,1
    FROM [Staging.CustomerAddress]
    WHERE ContactId IS NULL

	INSERT INTO CS_CustomerContactType (ContactTypeId, CustomerContactId)
	SELECT 1, ContactId
	FROM @ContactIds

	UPDATE  con
	SET con.Email = sta.ContactEmail
	FROM [Staging.CustomerAddress] sta
	JOIN CS_CustomerContact con ON con.CustomerContactId = sta.ContactId

    UPDATE sta
    SET sta.ContactId = con.CustomerContactId
    FROM [Staging.CustomerAddress] sta
    JOIN CS_CustomerContact con ON con.CustomerId = sta.CustomerId
        AND rtrim(isnull(con.FirstName, '') + ' ' + isnull(con.LastName, '')) = rtrim(isnull(sta.ContactPerson, ''))

    update sta
    set PhoneId1 = (select max(cp.CustomerPhoneId) from CS_CustomerPhone cp where cp.CustomerContactId = sta.ContactId and rtrim(isnull(cp.Number,'')) = rtrim(isnull(sta.CustomerPhone1, ''))) --group by CustomerContactId, Number)
    ,PhoneId2 = (select max(cp.CustomerPhoneId) from CS_CustomerPhone cp where cp.CustomerContactId = sta.ContactId and rtrim(isnull(cp.Number,'')) = rtrim(isnull(sta.CustomerPhone2, ''))) -- group by CustomerContactId, Number)
    ,PhoneId3 = (select max(cp.CustomerPhoneId) from CS_CustomerPhone cp where cp.CustomerContactId = sta.ContactId and rtrim(isnull(cp.Number,'')) = rtrim(isnull(sta.CustomerPhone3, ''))) -- group by CustomerContactId, Number)
    from [Staging.CustomerAddress] sta

    INSERT INTO [dbo].[CS_CustomerPhone] (
        [CustomerContactId]
        ,[Number]
        ,[IsMain]
        ) (
        SELECT ContactId
        ,CustomerPhone1
        ,0 FROM [Staging.CustomerAddress] WHERE rtrim(isnull(CustomerPhone1, '')) <> '' and PhoneId1 is null
        GROUP BY ContactId, CustomerPhone1
    
    UNION ALL
        
        SELECT ContactId
        ,CustomerPhone2
        ,0 FROM [Staging.CustomerAddress] WHERE rtrim(isnull(CustomerPhone2, '')) <> '' and PhoneId2 is null
        GROUP BY ContactId, CustomerPhone2
    
    UNION ALL
        
        SELECT ContactId
        ,CustomerPhone3
        ,0 FROM [Staging.CustomerAddress] WHERE rtrim(isnull(CustomerPhone3, '')) <> '' and PhoneId3 is null
        GROUP BY ContactId, CustomerPhone3
        )

    DELETE [Staging.CustomerAddress]
END
    --GO

GO


