load data 
infile 'Advertisers.dat' 
into table advertisers 
fields terminated by "\t" 
(advertiserid,
budget,
ctc)