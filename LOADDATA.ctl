load data 
infile 'Queries.dat' 
into table queries 
fields terminated by  "(tab)"
(
qid,
query
);
load data 
infile 'Advertisers.dat' 
into table advertisers 
fields terminated by "(tab)" 
(advertiserid,
budget,
ctc);
load data 
infile 'Keywords.dat' 
into table keywords 
fields terminated by "(tab)" 
(advertiserid,
keyword,
bid);