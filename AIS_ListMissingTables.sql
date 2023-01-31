SELECT	Name
FROM    AISTE.DBO.sysobjects
WHERE   xtype = 'U' and
	Name not in (SELECT Name
FROM    AIS.dbo.sysobjects
WHERE   xtype = 'U') AND
	LEFT(Name, 2) = 'PA'
ORDER BY 1