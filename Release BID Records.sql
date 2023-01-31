SELECT	Equipment, EquipmentSize, Lot_Road, Container, CustomerNumber
FROM	Repairs
WHERE	--Mechanic = '550'
		Equipment IN ('APMZ413783','HJCZ120432','HLC845597','OOLZ48169','KKLZ408914','TAXZ190520','FLXZ439272','MOFZ650447','TAXZ142481')
		and tablet is null
order by 1
/*
DELETE	Repairs
WHERE	Equipment IN ('APMZ413783','HJCZ120432','HLC845597','OOLZ48169','KKLZ408914','TAXZ190520','FLXZ439272','MOFZ650447','TAXZ142481')
		and tablet is null
		AND BIDStatus = 9
		*/