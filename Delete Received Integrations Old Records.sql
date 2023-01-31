delete	ReceivedIntegrations
where	ReceivedOn < DATEADD(dd, -5, getdate())