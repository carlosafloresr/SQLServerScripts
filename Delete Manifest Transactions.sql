DELETE	EquipmentDetails
WHERE	Fk_TransactionId IN (
							SELECT	TransactionId
							FROM	Transactions
							WHERE	CreatedOn > '03/01/2015'
							)

DELETE	AdditionalValues
WHERE	Fk_TransactionId IN (
							SELECT	TransactionId
							FROM	Transactions
							WHERE	CreatedOn > '03/01/2015'
							)

DELETE	Transactions
WHERE	CreatedOn > '03/01/2015'