IF EXISTS(select 1 from sys.objects where [name] = 'test_object')
BEGIN 
DROP TABLE test_object
END
GO
CREATE TABLE test_object(LocalIndex int IDENTITY(1,1) NOT NULL
						,TextOfSomeSort varchar(10) NOT NULL
						,NumberOfSomeSort varchar(10) NOT NULL
						,DateOfSomeSort varchar(10) not null
						)
GO
INSERT INTO test_object(TextOfSomeSort,NumberOfSomeSort,DateOfSomeSort) VALUES('a','5','20210101')
INSERT INTO test_object(TextOfSomeSort,NumberOfSomeSort,DateOfSomeSort) VALUES('b','4','20210102')
INSERT INTO test_object(TextOfSomeSort,NumberOfSomeSort,DateOfSomeSort) VALUES('c','3','20210103')
INSERT INTO test_object(TextOfSomeSort,NumberOfSomeSort,DateOfSomeSort) VALUES('d','2','20210104')
INSERT INTO test_object(TextOfSomeSort,NumberOfSomeSort,DateOfSomeSort) VALUES('e','1','20210105')
GO
select *
from test_object
GO
exec uspAdmin_DetermineImportedTableCharacteristics @table='test_object'
GO
DROP TABLE test_object
GO
/*
TableName	ColumnName	ColumnMeasure	ColumnValue1	PercentageOfRecords	ColumnMin	ColumnMax
test_object	DateOfSomeSort	Maximum length	8	NULL	20210101	20210105
test_object	DateOfSomeSort	NULL fields	0	0	20210101	20210105
test_object	DateOfSomeSort	Valid dates	5	100	20210101	20210105
test_object	DateOfSomeSort	Valid numbers	5	100	20210101	20210105
test_object	LocalIndex	Maximum length	1	NULL	1	5
test_object	LocalIndex	NULL fields	0	0	1	5
test_object	LocalIndex	Valid dates	0	0	1	5
test_object	LocalIndex	Valid numbers	5	100	1	5
test_object	NumberOfSomeSort	Maximum length	1	NULL	1	5
test_object	NumberOfSomeSort	NULL fields	0	0	1	5
test_object	NumberOfSomeSort	Valid dates	0	0	1	5
test_object	NumberOfSomeSort	Valid numbers	5	100	1	5
test_object	test_object	Record count	5	100	NULL	NULL
test_object	TextOfSomeSort	Maximum length	1	NULL	a	e
test_object	TextOfSomeSort	NULL fields	0	0	a	e
test_object	TextOfSomeSort	Valid dates	0	0	a	e
test_object	TextOfSomeSort	Valid numbers	0	0	a	e
*/