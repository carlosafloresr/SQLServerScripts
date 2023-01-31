-- select * from AIS_History WHERE AMOUNT < 0

select * from ilsint01.integrations.dbo.integrations_ap WHERE VCHNUMWK IN (select VOUCHER from AIS_History WHERE AMOUNT < 0)

UPDATE ilsint01.integrations.dbo.integrations_ap SET dOCTYPE = 5 WHERE VCHNUMWK IN (select VOUCHER from AIS_History WHERE AMOUNT < 0)

ilsint01.integrations.dbo.integrations_ap WHERE VCHNUMWK IN (select VOUCHER from AIS_History WHERE AMOUNT < 0)