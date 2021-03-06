commit;
drop table querytokens;
drop table bidders;
drop table qualityscores;
commit;
CREATE TABLE QUERYTOKENS (QID INTEGER, TOKEN VARCHAR(400), TCOUNT NUMBER);
CREATE TABLE BIDDERS(queryid NUMBER, advertiserid NUMBER, bidsum NUMBER, qualityscore FLOAT);
create table qualityscores(qu integer, ai integer, qs float);
commit;
drop table budget;
drop table TASK1ads;
drop table task2ads;
drop table task3ads;
drop table task12ads;
drop table task22ads;
drop table task32ads;
commit;
create table budget as (select advertiserid, budget as BUDGET_GR1, budget as BUDGET_GR2, budget as BUDGET_BA1, budget as BUDGET_BA2, budget as BUDGET_GE1, budget as BUDGET_GE2 from advertisers);
alter table budget add (adcount1 number, adcount2 number, adcount3 number, adcount4 number, adcount5 number, adcount6 number);
update budget set adcount1=0, adcount2 = 0, adcount3 = 0, adcount4 = 0, adcount5 = 0, adcount6 = 0;
commit;
CREATE table TASK1ADS (QID INTEGER, RANK INTEGER, ADVERTISERID INTEGER, BALANCE NUMBER, BUDGET1 NUMBER);
CREATE table TASK2ADS as (select * from task1ads);
CREATE table TASK3ADS as (select * from task1ads);
CREATE table TASK12ADS as (select * from task1ads);
CREATE table TASK22ADS as (select * from task1ads);
CREATE table TASK32ADS as (select * from task1ads);

drop table adcount;
create table adcount as (select advertiserid, adcount1, adcount2, adcount3, adcount4, adcount5, adcount6 from budget);
commit;
exit;