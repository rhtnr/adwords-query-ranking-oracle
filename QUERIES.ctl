load data 
infile 'Queries.dat' 
into table queries 
fields terminated by  "\t"
(
qid,
query
)