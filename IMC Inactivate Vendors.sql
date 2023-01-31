-- update imc.dbo.PM00200 set VendStts = 2 where PATINDEX('%TERM%', VendName) > 0

select * from imc.dbo.PM00200
update imc.dbo.PM00200 set VendStts = 2
WHERE	(PATINDEX('% TERM%', VendName) > 0 or PATINDEX('%-TERM%', VendName) > 0) and 
		PATINDEX('%INTERM%', VendName) = 0 AND
		PATINDEX('%TERMINALS%', VendName) = 0 AND 
		VENDORID NOT IN ('15401','1393','1576','11504')