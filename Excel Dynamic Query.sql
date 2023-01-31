let
//Pull in a values from the parameter table
dbURL = "LENSASQL002",
dbName = "Claims",
sYearValue = Text.From(fnGetParameter("Year")),
sMonthValue = Text.From(fnGetParameter("Month")),

//Create the query
dbQuery = "EXECUTE USP_ClaimsSummary_Report 'AIS','" & sYearValue & "','" & sMonthValue & "'",

//Get the data
Source = Sql.Database(dbURL,dbName,[Query=dbQuery])
in
Source