load data 
infile 'Keywords.dat' 
into table keywords 
fields terminated by "\t" 
(advertiserid,
keyword,
bid)