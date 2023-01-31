SELECT * FROM ilsint01.integrations.dbo.integrations_ap order by docamnt, DOCNUMBR

-- UPDATE ilsint01.integrations.dbo.integrations_ap SET DISTTYPE = 2 WHERE crdtamnt <> 0 AND DocType = 1
-- UPDATE ilsint01.integrations.dbo.integrations_ap SET DOCNUMBR = RTRIM(LTRIM(DOCNUMBR))
-- UPDATE ilsint01.integrations.dbo.integrations_ap SET batchid = 'AIS-HISTRECOVRY' where docnumbr in ('A0430 ATP 12-18516', 'PIP00000000000000139','A0221 ATP 05-40458')

-- SELECT * FROM PM10100