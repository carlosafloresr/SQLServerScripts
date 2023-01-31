update	gl20000
set		Refrence = 'OHC overpay refund',
		Dscriptn = 'OHC overpay refund'
FROM	(
select	Gl.Jrnentry
		,GL.Refrence
		,GL.Dscriptn
		,gl.orctrnum
		,PM.DistRef
		,gl.origseqnum
		,gl.actindx
		,gl.dex_row_Id
		,g5.ActNumst
		,gl.crdtamnt
		,gl.debitamt
from	gl20000 gl
		left join pm30600 pm on gl.orgntsrc = pm.trxsorce AND gl.actindx = pm.dstindx
		left join gl00105 g5 on gl.actindx = g5.actindx
where	--sourcdoc = 'PMTRX' and trxdate > '10/01/2008'
		--and GL.Dscriptn <> PM.DistRef
		Jrnentry IN (227283)
		--and gl.actindx = 705
		--AND g5.actnumst = '0-00-6460'
		--and gl.orctrnum = 'IAJ000002576'
		) RECS
WHERE	gl20000.dex_row_Id =  recs.dex_row_Id
		
/*

SELECT * FROM gl20000 WHERE Jrnentry = 17966 AND CrdtAmnt + DebitAmt = 249.60
UPDATE gl20000 SET Dscriptn = 'CPW' WHERE Jrnentry = 17797 AND CrdtAmnt + DebitAmt = 20.15

select * from PM10100 where right(rtrim(vchrnmbr), 4) = '5205'

SELECT * FROM gl20000 WHERE Jrnentry = 17938 and orgntsrc = 'PMTRX00000944'

select gl.*
from	gl20000 gl
		left join pm30200 pm on gl.orgntsrc = pm.trxsorce
where	sourcdoc = 'PMTRX' and trxdate > '08/30/2008'
		and gl.orctrnum = ''
		and pm.trxsorce is null
		
UPDATE	GL20000
SET		GL20000.Dscriptn = ORG.DistRef
FROM	(select	Gl.Jrnentry
		,GL.Refrence
		,GL.Dscriptn
		,gl.orctrnum
		,PM.DistRef
		,gl.origseqnum
		,gl.dex_row_Id
from	gl20000 gl
		left join pm30600 pm on gl.orgntsrc = pm.trxsorce AND gl.actindx = pm.dstindx
where	sourcdoc = 'PMTRX' and trxdate > '08/30/2008'
		and GL.Dscriptn <> PM.DistRef) ORG
WHERE	GL20000.dex_row_Id = ORG.dex_row_Id
*/