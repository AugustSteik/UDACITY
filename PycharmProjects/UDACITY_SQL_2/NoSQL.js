

--MongoDB

--SELECTing where NOT LIKE:

db.presidents.find({
	firstname: {
		$not: { $eq: 'George'} --i.e. NOT EQUAL
		}
	})


--Similarly for OR:

db.presidents.find({
		$or: [
			{LastName: 'George'},
			{lastName: 'Jefferson'}
		]
})

-- SELECTing data:
db.presidents.find({}).pretty()

