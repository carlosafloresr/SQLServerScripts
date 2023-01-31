DECLARE @tblVendors TABLE (
	[Vendor ID]			[char](15) NOT NULL,
	[Vendor Name]		[char](65) NOT NULL,
	[vendstts]			[smallint] NOT NULL,
	[Address1]			[char](61) NOT NULL,
	[Address2]			[char](61) NOT NULL,
	[Address3]			[char](61) NOT NULL,
	[City]				[char](35) NOT NULL,
	[State]				[char](29) NOT NULL,
	[Zip Codse]			[char](11) NOT NULL,
	[Country]			[char](61) NOT NULL,
	[vndclsid]			[char](11) NOT NULL,
	[Payment Terms]		[char](21) NOT NULL,
	[Total 12 Mo]		[nvarchar](50) NULL,
	[Contact]			[char](61) NOT NULL,
	[Tax ID]			[char](11) NOT NULL,
	[Email]				[varchar](30) NULL,
	[EFT Status]		[tinyint] NULL
)

INSERT INTO @tblVendors
SELECT	M.Vendorid as "Vendor ID", 
		m.vendname as "Vendor Name", 
		m.vendstts, 
		m.address1 as Address1, 
		m.address2 as Address2, 
		m.address3 as Address3, 
		m.city as City, 
		m.state as State, 
		m.zipcode as "Zip Codse", 
		m.country as Country, 
		m.vndclsid, 
		m.pymtrmid as "Payment Terms",
		format(sum(t.docamnt * CASE WHEN doctype >= 5 THEN -1 ELSE 1 END),'N','en-us') as "Total 12 Mo", 
		m.VNDCNTCT as Contact, 
		m.TXIDNMBR as "Tax ID",
		CAST(i.EmailToAddress as varchar) as Email, 
		e.INACTIVE as "EFT Status"
FROM	PM30200 t
		INNER JOIN PM00200 m on m.vendorid = t.vendorid
		LEFT JOIN SY01200 i on i.Master_ID = m.VENDORID and i.adrscode=m.VADDCDPR
		LEFT JOIN SY06000 e on e.CustomerVendor_ID = m.VENDORID
WHERE	t.docdate between '12/30/2016' and '12/31/2017' 
		and doctype <> '6' 
		and voided = 0
		and m.vndclsid <> 'DRV'
GROUP BY
		M.VEndorid, m.VENDNAME, m.vendstts, m.address1, m.address2, m.address3, m.city, m.state,
		m.zipcode, m.country, m.vndclsid, m.pymtrmid, m.TXIDNMBR, CAST(i.EmailToAddress as varchar),
		m.VNDCNTCT, e.INACTIVE
ORDER BY  m.vendorid

SELECT	*
FROM	@tblVendors