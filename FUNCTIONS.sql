CREATE OR REPLACE FUNCTION qualityscore(qid IN NUMBER,aid IN NUMBER)
RETURN FLOAT
IS
i_temp number;
i_temp2 number;
ascalar number;
bscalar number;
scalar number;
asq number;
bsq number;
i_ctc number;
present number;
qspresent number;
BEGIN
present:=0;
select count(*) into present from qualityscores where qu=qid and ai=aid;
if present = 1
then
  select qs into qspresent from qualityscores where qu=qid and ai=aid;
  return qspresent;
end if;
scalar:=0;
asq:=0;
bsq:=0;
i_temp:=qid;
FOR tokenset in (select * from querytokens where qid=i_temp)
LOOP
  ascalar:=tokenset.tcount;
  select count(keyword) into bscalar from keywords a where a.advertiserid=aid and keyword=tokenset.token;
  scalar:=scalar + (ascalar * bscalar);
END LOOP;
select sum(tcount*tcount) into asq from querytokens where qid=i_temp;
select count(keyword) into bsq from keywords a where a.advertiserid=aid;
i_temp2:=scalar/((sqrt(asq))*(sqrt(bsq)));
select ctc into i_ctc from advertisers a where a.advertiserid=aid;
RETURN i_ctc*i_temp2;
END;
/

CREATE OR REPLACE FUNCTION TASK1(q in number, topk in number)
RETURN NUMBER
IS
PRAGMA AUTONOMOUS_TRANSACTION;

i_temp number;
i_temp2 float;
i_temp3 float;
i_ctc number;
i_modadcount number;
cursor ctokens(id QUERIES.qid%type) is
     select word, count(word) as tcount from (with t as (select query as txt from queries where qid=id) select REGEXP_SUBSTR (txt, '[^[:space:]]+', 1, level) as word from t connect by level <= length(regexp_replace(txt,'[^[:space:]]+'))+1) where word !=' ' group by word;

BEGIN
FOR tokens in ctokens(q)
 LOOP
    select count(*) into i_temp from QUERYTOKENS where QUERYTOKENS.qid=q and QUERYTOKENS.token=tokens.word;
    IF i_temp = 0
    then
      INSERT INTO QUERYTOKENS(QID,TOKEN, tcount)  VALUES(q,tokens.word, tokens.tcount);
      commit;
      end if;
END LOOP;
commit;
--JOIN TOKENS with KEYWORDS
FOR ADS IN (select k.advertiserid, sum(bid) as bidsum from keywords k, querytokens q
where lower(q.token)=lower(k.keyword) and
q.qid=q
group by k.advertiserid having sum(bid)<=(select BUDGET_GR1 from budget where advertiserid=k.advertiserid))
LOOP
  INSERT INTO BIDDERS(queryid, advertiserid, bidsum, qualityscore) VALUES (q, ADS.advertiserid, ADS.bidsum, qualityscore(q,ADS.advertiserid));
  commit;
END LOOP;

FOR ADS IN (select rownum, queryid, advertiserid, bidsum, qualityscore from (SELECT * from BIDDERS WHERE queryid=q order by (bidsum*qualityscore) desc, ADVERTISERID) bidders2 where rownum<=topk order by rownum)
LOOP
  select ctc*100 into i_ctc from advertisers where advertiserid=ads.advertiserid;
  SELECT adcount1 into i_modadcount from adcount where advertiserid=ads.advertiserid;
   update adcount set adcount1=adcount1+1 where advertiserid=ads.advertiserid;
  IF  (((MOD(i_modadcount,100)) >= 0) and ((MOD(i_modadcount,100)) < i_ctc))
  THEN
    update budget set BUDGET_GR1=BUDGET_GR1 - ADS.bidsum where advertiserid=ads.advertiserid;
    commit;
   END IF;
   select BUDGET_GR1 into i_temp3 from budget where advertiserid=ads.advertiserid;
   select budget into i_temp2 from advertisers where advertiserid=ads.advertiserid;
   --CREATE TABLE TASK1ADS (QID INTEGER, RANK INTEGER, ADVERTISERID INTEGER, BALANCE FLOAT, BUDGET FLOAT);
   INSERT INTO TASK1ADS(qid, rank, advertiserid, balance, budget1) values(ADS.queryid, ads.rownum, ads.advertiserid, i_temp3, i_temp2 );-- , itemp2);
   commit;
END LOOP;


commit;
return 0;
END;
/
CREATE OR REPLACE FUNCTION TASK2(q in number, topk in number)
RETURN NUMBER
IS
PRAGMA AUTONOMOUS_TRANSACTION;

i_temp number;
i_temp2 float;
i_temp3 float;
i_ctc number;
i_modadcount number;
cursor ctokens(id QUERIES.qid%type) is
     select word, count(word) as tcount from (with t as (select query as txt from queries where qid=id) select REGEXP_SUBSTR (txt, '[^[:space:]]+', 1, level) as word from t connect by level <= length(regexp_replace(txt,'[^[:space:]]+'))+1) where word !=' ' group by word;

BEGIN
--split query into tokens
select count(*) into i_temp from QUERYTOKENS where QUERYTOKENS.qid=q;
if i_temp = 0 then
      FOR tokens in ctokens(q)
      LOOP
          select count(*) into i_temp from QUERYTOKENS where QUERYTOKENS.qid=q and QUERYTOKENS.token=tokens.word;
          IF i_temp = 0
          then
            INSERT INTO QUERYTOKENS(QID,TOKEN, tcount)  VALUES(q,tokens.word, tokens.tcount);
            commit;
            end if;
      END LOOP;
  commit;
end if;


--JOIN TOKENS with KEYWORDS
delete from bidders;
commit;
      FOR ADS IN (select k.advertiserid, sum(bid) as bidsum from keywords k, querytokens q
      where lower(q.token)=lower(k.keyword) and
      q.qid=q
      group by k.advertiserid having sum(bid)<=(select BUDGET_BA1 from budget where advertiserid=k.advertiserid))
      LOOP
        INSERT INTO BIDDERS(queryid, advertiserid, bidsum, qualityscore) VALUES (q, ADS.advertiserid, ADS.bidsum, qualityscore(q,ADS.advertiserid));
        commit;
    END LOOP;


--select final bidders
FOR ADS IN (select rownum, queryid, advertiserid, bidsum, qualityscore from (SELECT * from BIDDERS WHERE queryid=q order by((select BUDGET_BA1 from budget where advertiserid=bidders.advertiserid)*qualityscore) desc, ADVERTISERID) bidders2 where rownum<=topk order by rownum)
LOOP
  select ctc*100 into i_ctc from advertisers where advertiserid=ads.advertiserid;
  SELECT adcount2 into i_modadcount from adcount where advertiserid=ads.advertiserid;
   update adcount set adcount2=adcount2+1 where advertiserid=ads.advertiserid;
  IF  (((MOD(i_modadcount,100)) >= 0) and ((MOD(i_modadcount,100)) < i_ctc))
  THEN
    update budget set BUDGET_BA1=BUDGET_BA1 - ADS.bidsum where advertiserid=ads.advertiserid;
    commit;
   END IF;
   select BUDGET_BA1 into i_temp3 from budget where advertiserid=ads.advertiserid;
   select budget into i_temp2 from advertisers where advertiserid=ads.advertiserid;
   --CREATE TABLE TASK1ADS (QID INTEGER, RANK INTEGER, ADVERTISERID INTEGER, BALANCE FLOAT, BUDGET FLOAT);
   INSERT INTO TASK2ADS(qid, rank, advertiserid, balance, budget1) values(ADS.queryid, ads.rownum, ads.advertiserid, i_temp3, i_temp2 );-- , itemp2);
   commit;
END LOOP;


commit;
return 0;
END;
/
CREATE OR REPLACE FUNCTION TASK3(q in number, topk in number)
RETURN NUMBER
IS
PRAGMA AUTONOMOUS_TRANSACTION;

i_temp number;
i_temp2 float;
i_temp3 float;
i_ctc number;
i_modadcount number;
cursor ctokens(id QUERIES.qid%type) is
     select word, count(word) as tcount from (with t as (select query as txt from queries where qid=id) select REGEXP_SUBSTR (txt, '[^[:space:]]+', 1, level) as word from t connect by level <= length(regexp_replace(txt,'[^[:space:]]+'))+1) where word !=' ' group by word;

BEGIN
--split query into tokens
select count(*) into i_temp from QUERYTOKENS where QUERYTOKENS.qid=q;
if i_temp = 0 then
      FOR tokens in ctokens(q)
      LOOP
          select count(*) into i_temp from QUERYTOKENS where QUERYTOKENS.qid=q and QUERYTOKENS.token=tokens.word;
          IF i_temp = 0
          then
            INSERT INTO QUERYTOKENS(QID,TOKEN, tcount)  VALUES(q,tokens.word, tokens.tcount);
            commit;
            end if;
      END LOOP;
  commit;
end if;


--JOIN TOKENS with KEYWORDS
delete from bidders;
      FOR ADS IN (select k.advertiserid, sum(bid) as bidsum from keywords k, querytokens q
      where lower(q.token)=lower(k.keyword) and
      q.qid=q
      group by k.advertiserid having sum(bid)<=(select BUDGET_GE1 from budget where advertiserid=k.advertiserid))
      LOOP
        INSERT INTO BIDDERS(queryid, advertiserid, bidsum, qualityscore) VALUES (q, ADS.advertiserid, ADS.bidsum, qualityscore(q,ADS.advertiserid));
        commit;
    END LOOP;


--select final bidders
FOR ADS IN (select rownum, queryid, advertiserid, bidsum, qualityscore from (SELECT * from BIDDERS WHERE queryid=q order by(((BIDDERS.bidsum*(1-POWER(2.71828,(-(select BUDGET_GE1 from budget where budget.advertiserid=BIDDERS.advertiserid)/(select advertisers.budget from advertisers where advertisers.advertiserid=bidders.advertiserid))))))*qualityscore) desc, ADVERTISERID) bidders2 where rownum<=topk order by rownum)
LOOP
  select ctc*100 into i_ctc from advertisers where advertiserid=ads.advertiserid;
  SELECT adcount3 into i_modadcount from adcount where advertiserid=ads.advertiserid;
   update adcount set adcount3=adcount3+1 where advertiserid=ads.advertiserid;
  IF  (((MOD(i_modadcount,100)) >= 0) and ((MOD(i_modadcount,100)) < i_ctc))
  THEN
    update budget set BUDGET_GE1=BUDGET_GE1 - ADS.bidsum where advertiserid=ads.advertiserid;
    commit;
   END IF;
   select BUDGET_GE1 into i_temp3 from budget where advertiserid=ads.advertiserid;
   select budget into i_temp2 from advertisers where advertiserid=ads.advertiserid;
   --CREATE TABLE TASK1ADS (QID INTEGER, RANK INTEGER, ADVERTISERID INTEGER, BALANCE FLOAT, BUDGET FLOAT);
   INSERT INTO TASK3ADS(qid, rank, advertiserid, balance, budget1) values(ADS.queryid, ads.rownum, ads.advertiserid, i_temp3, i_temp2 );-- , itemp2);
   commit;
END LOOP;


commit;
return 0;
END;
/
CREATE OR REPLACE FUNCTION TASK12(q in number, topk in number)
RETURN NUMBER
IS
PRAGMA AUTONOMOUS_TRANSACTION;

i_temp number;
i_temp2 float;
i_temp3 float;
i_ctc number;
secbidder number;
i_modadcount number;
cursor ctokens(id QUERIES.qid%type) is
     select word, count(word) as tcount from (with t as (select query as txt from queries where qid=id) select REGEXP_SUBSTR (txt, '[^[:space:]]+', 1, level) as word from t connect by level <= length(regexp_replace(txt,'[^[:space:]]+'))+1) where word !=' ' group by word;

BEGIN
select count(*) into i_temp from QUERYTOKENS where QUERYTOKENS.qid=q;
if i_temp = 0 then
    FOR tokens in ctokens(q)
    LOOP
        select count(*) into i_temp from QUERYTOKENS where QUERYTOKENS.qid=q and QUERYTOKENS.token=tokens.word;
        IF i_temp = 0
        then
          INSERT INTO QUERYTOKENS(QID,TOKEN, tcount)  VALUES(q,tokens.word, tokens.tcount);
          commit;
          end if;
    END LOOP;
  commit;
  end if;
--JOIN TOKENS with KEYWORDS
delete from bidders;
FOR ADS IN (select k.advertiserid, sum(bid) as bidsum from keywords k, querytokens q
where lower(q.token)=lower(k.keyword) and
q.qid=q
group by k.advertiserid having sum(bid)<=(select BUDGET_GR2 from budget where advertiserid=k.advertiserid))
LOOP
  INSERT INTO BIDDERS(queryid, advertiserid, bidsum, qualityscore) VALUES (q, ADS.advertiserid, ADS.bidsum, qualityscore(q,ADS.advertiserid));
  commit;
END LOOP;

FOR ADS IN (select rownum, queryid, advertiserid, bidsum, qualityscore from (SELECT * from BIDDERS WHERE queryid=q order by (bidsum*qualityscore) desc, ADVERTISERID) bidders2 where rownum<=topk order by rownum)
LOOP
  select ctc*100 into i_ctc from advertisers where advertiserid=ads.advertiserid;
  SELECT adcount4 into i_modadcount from adcount where advertiserid=ads.advertiserid;
   update adcount set adcount4=adcount4+1 where advertiserid=ads.advertiserid;
  IF  (((MOD(i_modadcount,100)) >= 0) and ((MOD(i_modadcount,100)) < i_ctc))
  THEN
    secbidder:=-1;
    select max(distinct bidsum) into secbidder from bidders where bidsum<(select bidsum from bidders where queryid=q and advertiserid=ads.advertiserid);
    if (secbidder=-1) or secbidder is null then
      update budget set BUDGET_GR2=BUDGET_GR2 - ADS.bidsum where advertiserid=ads.advertiserid;
    else
      update budget set BUDGET_GR2=BUDGET_GR2 - secbidder where advertiserid=ads.advertiserid;
     end if;
    commit;
   END IF;
   select BUDGET_GR2 into i_temp3 from budget where advertiserid=ads.advertiserid;
   select budget into i_temp2 from advertisers where advertiserid=ads.advertiserid;
   --CREATE TABLE TASK1ADS (QID INTEGER, RANK INTEGER, ADVERTISERID INTEGER, BALANCE FLOAT, BUDGET FLOAT);
   INSERT INTO TASK12ADS(qid, rank, advertiserid, balance, budget1) values(ADS.queryid, ads.rownum, ads.advertiserid, i_temp3, i_temp2 );-- , itemp2);
   commit;
END LOOP;


commit;
return 0;
END;
/
CREATE OR REPLACE FUNCTION TASK22(q in number, topk in number)
RETURN NUMBER
IS
PRAGMA AUTONOMOUS_TRANSACTION;

i_temp number;
i_temp2 float;
i_temp3 float;
i_ctc number;
i_modadcount number;
secbidder number;
cursor ctokens(id QUERIES.qid%type) is
     select word, count(word) as tcount from (with t as (select query as txt from queries where qid=id) select REGEXP_SUBSTR (txt, '[^[:space:]]+', 1, level) as word from t connect by level <= length(regexp_replace(txt,'[^[:space:]]+'))+1) where word !=' ' group by word;

BEGIN
--split query into tokens
select count(*) into i_temp from QUERYTOKENS where QUERYTOKENS.qid=q;
if i_temp = 0 then
      FOR tokens in ctokens(q)
      LOOP
          select count(*) into i_temp from QUERYTOKENS where QUERYTOKENS.qid=q and QUERYTOKENS.token=tokens.word;
          IF i_temp = 0
          then
            INSERT INTO QUERYTOKENS(QID,TOKEN, tcount)  VALUES(q,tokens.word, tokens.tcount);
            commit;
            end if;
      END LOOP;
  commit;
end if;


--JOIN TOKENS with KEYWORDS
delete from bidders;
commit;
      FOR ADS IN (select k.advertiserid, sum(bid) as bidsum from keywords k, querytokens q
      where lower(q.token)=lower(k.keyword) and
      q.qid=q
      group by k.advertiserid having sum(bid)<=(select BUDGET_BA2 from budget where advertiserid=k.advertiserid))
      LOOP
        INSERT INTO BIDDERS(queryid, advertiserid, bidsum, qualityscore) VALUES (q, ADS.advertiserid, ADS.bidsum, qualityscore(q,ADS.advertiserid));
        commit;
    END LOOP;


--select final bidders
FOR ADS IN (select rownum, queryid, advertiserid, bidsum, qualityscore from (SELECT * from BIDDERS WHERE queryid=q order by((select BUDGET_BA2 from budget where advertiserid=bidders.advertiserid)*qualityscore) desc, ADVERTISERID) bidders2 where rownum<=topk order by rownum)
LOOP
  select ctc*100 into i_ctc from advertisers where advertiserid=ads.advertiserid;
  SELECT adcount5 into i_modadcount from adcount where advertiserid=ads.advertiserid;
   update adcount set adcount5=adcount5+1 where advertiserid=ads.advertiserid;
  IF  (((MOD(i_modadcount,100)) >= 0) and ((MOD(i_modadcount,100)) < i_ctc))
  THEN
    secbidder:=-1;
    select max(distinct bidsum) into secbidder from bidders where bidsum<(select bidsum from bidders where queryid=q and advertiserid=ads.advertiserid);
    if (secbidder=-1) or secbidder is null then
      update budget set BUDGET_BA2=BUDGET_BA2 - ADS.bidsum where advertiserid=ads.advertiserid;
    else
      update budget set BUDGET_BA2=BUDGET_BA2 - secbidder where advertiserid=ads.advertiserid;
     end if;
    commit;
   END IF;
   select BUDGET_BA2 into i_temp3 from budget where advertiserid=ads.advertiserid;
   select budget into i_temp2 from advertisers where advertiserid=ads.advertiserid;
   --CREATE TABLE TASK1ADS (QID INTEGER, RANK INTEGER, ADVERTISERID INTEGER, BALANCE FLOAT, BUDGET FLOAT);
   INSERT INTO TASK22ADS(qid, rank, advertiserid, balance, budget1) values(ADS.queryid, ads.rownum, ads.advertiserid, i_temp3, i_temp2 );-- , itemp2);
   commit;
END LOOP;


commit;
return 0;
END;
/
CREATE OR REPLACE FUNCTION TASK32(q in number, topk in number)
RETURN NUMBER
IS
PRAGMA AUTONOMOUS_TRANSACTION;

i_temp number;
i_temp2 float;
i_temp3 float;
i_ctc number;
i_modadcount number;
secbidder number;
cursor ctokens(id QUERIES.qid%type) is
     select word, count(word) as tcount from (with t as (select query as txt from queries where qid=id) select REGEXP_SUBSTR (txt, '[^[:space:]]+', 1, level) as word from t connect by level <= length(regexp_replace(txt,'[^[:space:]]+'))+1) where word !=' ' group by word;

BEGIN
--split query into tokens
select count(*) into i_temp from QUERYTOKENS where QUERYTOKENS.qid=q;
if i_temp = 0 then
      FOR tokens in ctokens(q)
      LOOP
          select count(*) into i_temp from QUERYTOKENS where QUERYTOKENS.qid=q and QUERYTOKENS.token=tokens.word;
          IF i_temp = 0
          then
            INSERT INTO QUERYTOKENS(QID,TOKEN, tcount)  VALUES(q,tokens.word, tokens.tcount);
            commit;
            end if;
      END LOOP;
  commit;
end if;


--JOIN TOKENS with KEYWORDS
delete from bidders;
commit;
      FOR ADS IN (select k.advertiserid, sum(bid) as bidsum from keywords k, querytokens q
      where lower(q.token)=lower(k.keyword) and
      q.qid=q
      group by k.advertiserid having sum(bid)<=(select BUDGET_GE2 from budget where advertiserid=k.advertiserid))
      LOOP
        INSERT INTO BIDDERS(queryid, advertiserid, bidsum, qualityscore) VALUES (q, ADS.advertiserid, ADS.bidsum, qualityscore(q,ADS.advertiserid));
        commit;
    END LOOP;


--select final bidders
FOR ADS IN (select rownum, queryid, advertiserid, bidsum, qualityscore from (SELECT * from BIDDERS WHERE queryid=q order by(((BIDDERS.bidsum*(1-POWER(2.71828,(-(select BUDGET_GE2 from budget where budget.advertiserid=BIDDERS.advertiserid)/(select advertisers.budget from advertisers where advertisers.advertiserid=bidders.advertiserid))))))*qualityscore) desc, ADVERTISERID) bidders2 where rownum<=topk order by rownum)
LOOP
  select ctc*100 into i_ctc from advertisers where advertiserid=ads.advertiserid;
  SELECT adcount6 into i_modadcount from adcount where advertiserid=ads.advertiserid;
   update adcount set adcount6=adcount6+1 where advertiserid=ads.advertiserid;
  IF  (((MOD(i_modadcount,100)) >= 0) and ((MOD(i_modadcount,100)) < i_ctc))
  THEN
    secbidder:=-1;
    select max(distinct bidsum) into secbidder from bidders where bidsum<(select bidsum from bidders where queryid=q and advertiserid=ads.advertiserid);
    if (secbidder=-1) or secbidder is null then
      update budget set BUDGET_GE2=BUDGET_GE2 - ADS.bidsum where advertiserid=ads.advertiserid;
    else
      update budget set BUDGET_GE2=BUDGET_GE2 - secbidder where advertiserid=ads.advertiserid;
     end if;
    commit;
   END IF;
   select BUDGET_GE2 into i_temp3 from budget where advertiserid=ads.advertiserid;
   select budget into i_temp2 from advertisers where advertiserid=ads.advertiserid;
   --CREATE TABLE TASK1ADS (QID INTEGER, RANK INTEGER, ADVERTISERID INTEGER, BALANCE FLOAT, BUDGET FLOAT);
   INSERT INTO TASK32ADS(qid, rank, advertiserid, balance, budget1) values(ADS.queryid, ads.rownum, ads.advertiserid, i_temp3, i_temp2 );-- , itemp2);
   commit;
END LOOP;


commit;
return 0;
END;
/
create or replace function tester(maxqid in number, scheme in number, topk in number)
return number
is
i_temp number;
LCalc number;
begin
IF scheme = 1 THEN
   FOR Lcntr IN 1..maxqid
      LOOP
        select task1(Lcntr, topk) into LCalc from dual;
    END LOOP;


ELSIF scheme = 2 THEN
   FOR Lcntr IN 1..maxqid
      LOOP
        select task12(Lcntr, topk) into LCalc from dual;
    END LOOP;

ELSIF scheme = 3 then
   FOR Lcntr IN 1..maxqid
      LOOP
        select task2(Lcntr, topk) into LCalc from dual;
    END LOOP;

ELSIF scheme = 4 then
   FOR Lcntr IN 1..maxqid
      LOOP
        select task22(Lcntr, topk) into LCalc from dual;
    END LOOP;

ELSIF scheme = 5 then
   FOR Lcntr IN 1..maxqid
      LOOP
        select task3(Lcntr, topk) into LCalc from dual;
    END LOOP;

ELSIF scheme = 6 then
   FOR Lcntr IN 1..maxqid
      LOOP
        select task32(Lcntr, topk) into LCalc from dual;
    END LOOP;


END IF;

return 0;
end;
/
commit;
exit;
