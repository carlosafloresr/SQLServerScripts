
--System.ServiceModel.CommunicationException: The maximum message size quota for incoming messages (1500000) has been exceeded
select * from CS_Invoice where InvoiceId = 3448548
select * from CS_Enterprise where EnterpriseId = 5

-- emails from 2018 not sent
select * from CS_Letter l
join CS_LetterContact lc on lc.LetterId = l.LetterId
join CS_CustomerContact con on con.CustomerContactId = lc.CustomerContactId
where l.WasSent = 0 and Email <> '' order by Date

-- contacts detected as invalid emails
select * from CS_CustomerContact where CustomerContactId in (
44119,
44128,
67115,
67123,
67125,
67126,
67133,
67236,
67378,
67415,
67441,
67442,
67443,
67450,
67456,
67480,
67546,
67554
)