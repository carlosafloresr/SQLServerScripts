SELECT	Company,
		CustomerNumber,
		InvoiceNumber
INTO	PaperlessInvoicing_Special
FROM	View_Integration_FSI_Sales
WHERE	InvoiceNumber IN ('72-100076-A',
'72-100077-A',
'72-100548-A',
'D31-163150',
'72-100565-A',
'2-274409',
'72-100468-A',
'96-101223-A',
'72-100886',
'21-264434-A',
'72-100824-A',
'21-265155-A',
'72-100825-A',
'72-100847-A',
'72-100867-A',
'72-100871-A',
'72-100872-A',
'72-100908-A',
'72-100915-A',
'72-100924-A',
'72-100930-A',
'72-100932-A',
'72-100937-A',
'72-100954-A',
'72-100973-A',
'72-100998-A',
'72-100999-A',
'72-101001-A',
'72-101002-A',
'72-101039-A',
'72-101040-A',
'72-101041-A',
'72-101044-A',
'72-101046-A',
'72-101047-A',
'72-101048-A',
'72-101049-A',
'72-101052-A',
'72-101055-A',
'72-101057-A',
'72-101058-A',
'72-101059-A',
'72-101060-A',
'72-101088-A',
'72-101089-A',
'72-101132-A',
'72-101137-A',
'72-101138-A',
'72-101139-A',
'72-101141-A',
'72-101143-A',
'72-101145-A',
'72-101146-A',
'72-101147-A',
'72-101148-A',
'72-101150-A',
'72-101201-A',
'72-101203-A',
'72-101204-A',
'72-101205-A',
'72-101210-A',
'7000A-D2-265676',
'D21-265154-A',
'21-262344-A',
'21-265642-A',
'21-265644-A',
'21-265645-A',
'72-100818-A',
'72-100834-A',
'72-100837-A',
'72-100840-A',
'72-100869-A',
'72-100870-A',
'72-100877-A',
'72-100907-A',
'72-100934-A',
'72-101045-A',
'72-101140-A',
'72-101144-A',
'72-101161-B',
'72-101162-A',
'72-101163-A',
'72-101164-A',
'72-101165-A',
'72-101227-A',
'72-101232-A',
'72-101233-A',
'72-101239-A',
'72-101310-B',
'72-101313-A',
'72-101314-A',
'72-101315-A',
'72-101317-A',
'72-101318-A',
'72-101042-A',
'72-101043-A',
'72-101050-A',
'72-101054-A',
'21-266234-A',
'21-266285-B',
'21-266290-D',
'21-266291-B',
'21-266292-B',
'21-266293-B',
'72-101000-A',
'72-101090-A',
'72-101208-B',
'7000A-96-101217-A',
'72-101051-A',
'72-101158-B',
'72-101213-A',
'72-101214-A',
'72-101215-A',
'72-101216-A',
'72-101217-A',
'72-101218-A',
'72-101219-A',
'72-101220-A',
'72-101221-A',
'72-101222-A',
'72-101303-B',
'72-101305-B',
'2-276840-A',
'2-277021-A',
'72-101160-B',
'72-101304-B',
'72-101319-A',
'21-266289-D',
'21-266294-C',
'72-101230-A',
'72-101320-A',
'72-101234-A',
'72-101183-B',
'72-101185-B',
'72-101192-C',
'72-101193-D',
'72-101194-D',
'72-101195-C',
'72-101196-C',
'72-101197-C',
'72-101198-C',
'96-101465-A',
'96-101467-A',
'96-101469-A',
'31-165388-B',
'72-101250-B',
'72-101251-B',
'72-101252-B',
'72-101253-B',
'72-101254-B',
'72-101256-B',
'72-101259-A',
'72-101270-A',
'72-101271-B',
'72-101306-B',
'72-101307-B',
'72-101308-B',
'72-101309-B',
'72-101322-B',
'72-101324-A',
'72-101325-B',
'72-101332-C',
'72-101340-A',
'72-101341-B',
'72-101380-B',
'72-101381-B',
'72-101182-B',
'72-101257-A',
'72-101323-B',
'72-101342-B',
'72-101382-B',
'72-101393',
'72-101394',
'96-101682-A',
'72-101186-B',
'72-101207-B',
'72-101311-B',
'72-101355-A',
'72-101356-A',
'72-101395',
'72-101396',
'72-101397',
'72-101398',
'D72-101209-A',
'72-101226-A',
'72-101301-B',
'72-101302-B',
'72-101326-B',
'72-101327-B',
'72-101352-A',
'72-101353-B',
'72-101418-B',
'72-101420-B',
'72-101441-B',
'72-101442-B',
'72-101479-B',
'21-266613-B',
'21-267140-B',
'21-267141-B',
'72-101229-B',
'72-101336-B',
'72-101444-B',
'96-101628',
'96-101640',
'96-101659',
'96-101577A')
and CustomerNumber = '7000A'
ORDER BY InvoiceDate