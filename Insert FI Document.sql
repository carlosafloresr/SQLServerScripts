-- SELECT * FROM FI_Documents WHERE LEFT(Document, 11) = 'MEMO_510948'

INSERT INTO [FI_Data].[dbo].[FI_Documents]
           ([Document]
           ,[DocType]
           ,[DocNumber]
           ,[Par_Type]
           ,[Par_Doc])
     VALUES
           ('MEMO_510948,475016_510948.PDF'
           ,'MEMO'
           ,'475016'
           ,'INV'
           ,'510948')
GO


