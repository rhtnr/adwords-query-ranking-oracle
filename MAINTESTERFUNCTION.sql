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