set hive.explain.user=false;
-- SORT_QUERY_RESULTS

--1. test1
explain
select p_mfgr, p_name, p_size,
rank() over (partition by p_mfgr order by p_name) as r,
dense_rank() over (partition by p_mfgr order by p_name) as dr,
round(sum(p_retailprice) over (partition by p_mfgr order by p_name rows between unbounded preceding and current row),2) as s1
from noop(on part 
  partition by p_mfgr
  order by p_name
  );

select p_mfgr, p_name, p_size,
rank() over (partition by p_mfgr order by p_name) as r,
dense_rank() over (partition by p_mfgr order by p_name) as dr,
round(sum(p_retailprice) over (partition by p_mfgr order by p_name rows between unbounded preceding and current row),2) as s1
from noop(on part 
  partition by p_mfgr
  order by p_name
  );

-- 2. testJoinWithNoop
explain
select p_mfgr, p_name,
p_size, p_size - lag(p_size,1,p_size) over (partition by p_mfgr order by p_name) as deltaSz
from noop (on (select p1.* from part p1 join part p2 on p1.p_partkey = p2.p_partkey) j
distribute by j.p_mfgr
sort by j.p_name)
;    

select p_mfgr, p_name,
p_size, p_size - lag(p_size,1,p_size) over (partition by p_mfgr order by p_name) as deltaSz
from noop (on (select p1.* from part p1 join part p2 on p1.p_partkey = p2.p_partkey) j
distribute by j.p_mfgr
sort by j.p_name)
;    

-- 3. testOnlyPTF
explain
select p_mfgr, p_name, p_size
from noop(on part
partition by p_mfgr
order by p_name);

select p_mfgr, p_name, p_size
from noop(on part
partition by p_mfgr
order by p_name);

-- 4. testPTFAlias
explain
select p_mfgr, p_name, p_size,
rank() over (partition by p_mfgr order by p_name) as r,
dense_rank() over (partition by p_mfgr order by p_name) as dr,
round(sum(p_retailprice) over (partition by p_mfgr order by p_name rows between unbounded preceding and current row),2) as s1
from noop(on part 
  partition by p_mfgr
  order by p_name
  ) abc;

select p_mfgr, p_name, p_size,
rank() over (partition by p_mfgr order by p_name) as r,
dense_rank() over (partition by p_mfgr order by p_name) as dr,
round(sum(p_retailprice) over (partition by p_mfgr order by p_name rows between unbounded preceding and current row),2) as s1
from noop(on part 
  partition by p_mfgr
  order by p_name
  ) abc;

-- 5. testPTFAndWhereWithWindowing
explain
select p_mfgr, p_name, p_size, 
rank() over (partition by p_mfgr order by p_name) as r, 
dense_rank() over (partition by p_mfgr order by p_name) as dr, 
p_size, p_size - lag(p_size,1,p_size) over (partition by p_mfgr order by p_name) as deltaSz 
from noop(on part 
          partition by p_mfgr 
          order by p_name 
          ) 
;

select p_mfgr, p_name, p_size, 
rank() over (partition by p_mfgr order by p_name) as r, 
dense_rank() over (partition by p_mfgr order by p_name) as dr, 
p_size, p_size - lag(p_size,1,p_size) over (partition by p_mfgr order by p_name) as deltaSz 
from noop(on part 
          partition by p_mfgr 
          order by p_name 
          ) 
;

-- 6. testSWQAndPTFAndGBy
explain
select p_mfgr, p_name, p_size, 
rank() over (partition by p_mfgr order by p_name) as r, 
dense_rank() over (partition by p_mfgr order by p_name) as dr, 
p_size, p_size - lag(p_size,1,p_size) over (partition by p_mfgr order by p_name) as deltaSz 
from noop(on part 
          partition by p_mfgr 
          order by p_name 
          ) 
group by p_mfgr, p_name, p_size  
;

select p_mfgr, p_name, p_size, 
rank() over (partition by p_mfgr order by p_name) as r, 
dense_rank() over (partition by p_mfgr order by p_name) as dr, 
p_size, p_size - lag(p_size,1,p_size) over (partition by p_mfgr order by p_name) as deltaSz 
from noop(on part 
          partition by p_mfgr 
          order by p_name 
          ) 
group by p_mfgr, p_name, p_size  
;

-- 7. testJoin
explain
select abc.* 
from noop(on part 
partition by p_mfgr 
order by p_name 
) abc join part p1 on abc.p_partkey = p1.p_partkey;

select abc.* 
from noop(on part 
partition by p_mfgr 
order by p_name 
) abc join part p1 on abc.p_partkey = p1.p_partkey;

-- 8. testJoinRight
explain
select abc.* 
from part p1 join noop(on part 
partition by p_mfgr 
order by p_name 
) abc on abc.p_partkey = p1.p_partkey;

select abc.* 
from part p1 join noop(on part 
partition by p_mfgr 
order by p_name 
) abc on abc.p_partkey = p1.p_partkey;

-- 9. testNoopWithMap
explain
select p_mfgr, p_name, p_size, 
rank() over (partition by p_mfgr order by p_name, p_size desc) as r
from noopwithmap(on part
partition by p_mfgr
order by p_name, p_size desc);

select p_mfgr, p_name, p_size, 
rank() over (partition by p_mfgr order by p_name, p_size desc) as r
from noopwithmap(on part
partition by p_mfgr
order by p_name, p_size desc);

-- 10. testNoopWithMapWithWindowing 
explain 
select p_mfgr, p_name, p_size,
rank() over (partition by p_mfgr order by p_name) as r,
dense_rank() over (partition by p_mfgr order by p_name) as dr,
round(sum(p_retailprice) over (partition by p_mfgr order by p_name rows between unbounded preceding and current row),2) as s1
from noopwithmap(on part 
  partition by p_mfgr
  order by p_name);

select p_mfgr, p_name, p_size,
rank() over (partition by p_mfgr order by p_name) as r,
dense_rank() over (partition by p_mfgr order by p_name) as dr,
round(sum(p_retailprice) over (partition by p_mfgr order by p_name rows between unbounded preceding and current row),2) as s1
from noopwithmap(on part 
  partition by p_mfgr
  order by p_name);
  
-- 11. testHavingWithWindowingPTFNoGBY
explain
select p_mfgr, p_name, p_size,
rank() over (partition by p_mfgr order by p_name) as r,
dense_rank() over (partition by p_mfgr order by p_name) as dr,
round(sum(p_retailprice) over (partition by p_mfgr order by p_name rows between unbounded preceding and current row),2) as s1
from noop(on part
partition by p_mfgr
order by p_name)
;

select p_mfgr, p_name, p_size,
rank() over (partition by p_mfgr order by p_name) as r,
dense_rank() over (partition by p_mfgr order by p_name) as dr,
round(sum(p_retailprice) over (partition by p_mfgr order by p_name rows between unbounded preceding and current row),2) as s1
from noop(on part
partition by p_mfgr
order by p_name)
;
  
-- 12. testFunctionChain
explain
select p_mfgr, p_name, p_size, 
rank() over (partition by p_mfgr order by p_name) as r, 
dense_rank() over (partition by p_mfgr order by p_name) as dr, 
round(sum(p_retailprice) over (partition by p_mfgr order by p_name rows between unbounded preceding and current row),2) as s1
from noop(on noopwithmap(on noop(on part 
partition by p_mfgr 
order by p_mfgr DESC, p_name
)));

select p_mfgr, p_name, p_size, 
rank() over (partition by p_mfgr order by p_name) as r, 
dense_rank() over (partition by p_mfgr order by p_name) as dr, 
round(sum(p_retailprice) over (partition by p_mfgr order by p_name rows between unbounded preceding and current row),2) as s1
from noop(on noopwithmap(on noop(on part 
partition by p_mfgr 
order by p_mfgr DESC, p_name
)));
 
-- 13. testPTFAndWindowingInSubQ
explain
select p_mfgr, p_name, 
sub1.cd, sub1.s1 
from (select p_mfgr, p_name, 
count(p_size) over (partition by p_mfgr order by p_name) as cd, 
p_retailprice, 
round(sum(p_retailprice) over w1,2) as s1
from noop(on part 
partition by p_mfgr 
order by p_name) 
window w1 as (partition by p_mfgr order by p_name rows between 2 preceding and 2 following) 
) sub1 ;

select p_mfgr, p_name, 
sub1.cd, sub1.s1 
from (select p_mfgr, p_name, 
count(p_size) over (partition by p_mfgr order by p_name) as cd, 
p_retailprice, 
round(sum(p_retailprice) over w1,2)  as s1
from noop(on part 
partition by p_mfgr 
order by p_name) 
window w1 as (partition by p_mfgr order by p_name rows between 2 preceding and 2 following) 
) sub1 ;

-- 14. testPTFJoinWithWindowingWithCount
explain
select abc.p_mfgr, abc.p_name, 
rank() over (distribute by abc.p_mfgr sort by abc.p_name) as r, 
dense_rank() over (distribute by abc.p_mfgr sort by abc.p_name) as dr, 
count(abc.p_name) over (distribute by abc.p_mfgr sort by abc.p_name) as cd, 
abc.p_retailprice, round(sum(abc.p_retailprice) over (distribute by abc.p_mfgr sort by abc.p_name rows between unbounded preceding and current row),2) as s1,
abc.p_size, abc.p_size - lag(abc.p_size,1,abc.p_size) over (distribute by abc.p_mfgr sort by abc.p_name) as deltaSz 
from noop(on part 
partition by p_mfgr 
order by p_name 
) abc join part p1 on abc.p_partkey = p1.p_partkey 
;

select abc.p_mfgr, abc.p_name, 
rank() over (distribute by abc.p_mfgr sort by abc.p_name) as r, 
dense_rank() over (distribute by abc.p_mfgr sort by abc.p_name) as dr, 
count(abc.p_name) over (distribute by abc.p_mfgr sort by abc.p_name) as cd,
abc.p_retailprice, round(sum(abc.p_retailprice) over (distribute by abc.p_mfgr sort by abc.p_name rows between unbounded preceding and current row),2) as s1,
abc.p_size, abc.p_size - lag(abc.p_size,1,abc.p_size) over (distribute by abc.p_mfgr sort by abc.p_name) as deltaSz 
from noop(on part 
partition by p_mfgr 
order by p_name 
) abc join part p1 on abc.p_partkey = p1.p_partkey 
;

-- 15. testDistinctInSelectWithPTF
explain
select DISTINCT p_mfgr, p_name, p_size 
from noop(on part 
partition by p_mfgr 
order by p_name);

select DISTINCT p_mfgr, p_name, p_size 
from noop(on part 
partition by p_mfgr 
order by p_name);

  
-- 16. testViewAsTableInputToPTF
create view IF NOT EXISTS mfgr_price_view as 
select p_mfgr, p_brand, 
round(sum(p_retailprice),2) as s
from part 
group by p_mfgr, p_brand;

explain
select p_mfgr, p_brand, s, 
round(sum(s) over w1,2)  as s1
from noop(on mfgr_price_view 
partition by p_mfgr 
order by p_mfgr)  
window w1 as ( partition by p_mfgr order by p_brand rows between 2 preceding and current row);

select p_mfgr, p_brand, s, 
round(sum(s) over w1,2) as s1
from noop(on mfgr_price_view 
partition by p_mfgr 
order by p_mfgr)  
window w1 as ( partition by p_mfgr order by p_brand rows between 2 preceding and current row);
  
-- 17. testMultipleInserts2SWQsWithPTF
CREATE TABLE part_4( 
p_mfgr STRING, 
p_name STRING, 
p_size INT, 
r INT, 
dr INT, 
s DOUBLE);

CREATE TABLE part_5( 
p_mfgr STRING, 
p_name STRING, 
p_size INT, 
s2 INT, 
r INT, 
dr INT, 
cud DOUBLE, 
fv1 INT);

explain
from noop(on part 
partition by p_mfgr 
order by p_name) 
INSERT OVERWRITE TABLE part_4 select p_mfgr, p_name, p_size, 
rank() over (distribute by p_mfgr sort by p_name) as r, 
dense_rank() over (distribute by p_mfgr sort by p_name) as dr, 
round(sum(p_retailprice) over (distribute by p_mfgr sort by p_name rows between unbounded preceding and current row),2)  as s
INSERT OVERWRITE TABLE part_5 select  p_mfgr,p_name, p_size,  
round(sum(p_size) over (distribute by p_mfgr sort by p_size range between 5 preceding and current row),1) as s2,
rank() over (distribute by p_mfgr sort by p_mfgr, p_name) as r, 
dense_rank() over (distribute by p_mfgr sort by p_mfgr, p_name) as dr, 
cume_dist() over (distribute by p_mfgr sort by p_mfgr, p_name) as cud, 
first_value(p_size, true) over w1  as fv1
window w1 as (distribute by p_mfgr sort by p_mfgr, p_name rows between 2 preceding and 2 following);

from noop(on part 
partition by p_mfgr 
order by p_name) 
INSERT OVERWRITE TABLE part_4 select p_mfgr, p_name, p_size, 
rank() over (distribute by p_mfgr sort by p_name) as r, 
dense_rank() over (distribute by p_mfgr sort by p_name) as dr, 
round(sum(p_retailprice) over (distribute by p_mfgr sort by p_name rows between unbounded preceding and current row),2)  as s
INSERT OVERWRITE TABLE part_5 select  p_mfgr,p_name, p_size,  
round(sum(p_size) over (distribute by p_mfgr sort by p_size range between 5 preceding and current row),1) as s2,
rank() over (distribute by p_mfgr sort by p_mfgr, p_name) as r, 
dense_rank() over (distribute by p_mfgr sort by p_mfgr, p_name) as dr, 
cume_dist() over (distribute by p_mfgr sort by p_mfgr, p_name) as cud, 
first_value(p_size, true) over w1  as fv1
window w1 as (distribute by p_mfgr sort by p_mfgr, p_name rows between 2 preceding and 2 following);

select * from part_4;

select * from part_5;

-- 18. testMulti2OperatorsFunctionChainWithMap
explain
select p_mfgr, p_name,  
rank() over (partition by p_mfgr,p_name) as r, 
dense_rank() over (partition by p_mfgr,p_name) as dr, 
p_size, sum(p_size) over (partition by p_mfgr,p_name rows between unbounded preceding and current row)  as s1
from noop(on 
        noopwithmap(on 
          noop(on 
              noop(on part 
              partition by p_mfgr 
              order by p_mfgr) 
            ) 
          partition by p_mfgr,p_name 
          order by p_mfgr,p_name) 
        partition by p_mfgr,p_name  
        order by p_mfgr,p_name) ;

select p_mfgr, p_name,  
rank() over (partition by p_mfgr,p_name) as r, 
dense_rank() over (partition by p_mfgr,p_name) as dr, 
p_size, sum(p_size) over (partition by p_mfgr,p_name rows between unbounded preceding and current row)  as s1
from noop(on 
        noopwithmap(on 
          noop(on 
              noop(on part 
              partition by p_mfgr 
              order by p_mfgr) 
            ) 
          partition by p_mfgr,p_name 
          order by p_mfgr,p_name) 
        partition by p_mfgr,p_name  
        order by p_mfgr,p_name) ;

-- 19. testMulti3OperatorsFunctionChain
explain
select p_mfgr, p_name,  
rank() over (partition by p_mfgr order by p_name) as r, 
dense_rank() over (partition by p_mfgr order by p_name) as dr, 
p_size, sum(p_size) over (partition by p_mfgr order by p_name rows between unbounded preceding and current row)  as s1
from noop(on 
        noop(on 
          noop(on 
              noop(on part 
              partition by p_mfgr 
              order by p_mfgr) 
            ) 
          partition by p_mfgr,p_name 
          order by p_mfgr,p_name) 
        partition by p_mfgr  
        order by p_mfgr ) ;

select p_mfgr, p_name,  
rank() over (partition by p_mfgr order by p_name) as r, 
dense_rank() over (partition by p_mfgr order by p_name) as dr, 
p_size, sum(p_size) over (partition by p_mfgr order by p_name rows between unbounded preceding and current row)  as s1
from noop(on 
        noop(on 
          noop(on 
              noop(on part 
              partition by p_mfgr 
              order by p_mfgr) 
            ) 
          partition by p_mfgr,p_name 
          order by p_mfgr,p_name) 
        partition by p_mfgr  
        order by p_mfgr ) ;
        
-- 20. testMultiOperatorChainWithNoWindowing
explain
select p_mfgr, p_name,  
rank() over (partition by p_mfgr order by p_name) as r, 
dense_rank() over (partition by p_mfgr order by p_name) as dr, 
p_size, sum(p_size) over (partition by p_mfgr order by p_name) as s1 
from noop(on 
        noop(on 
          noop(on 
              noop(on part 
              partition by p_mfgr,p_name 
              order by p_mfgr,p_name) 
            ) 
          partition by p_mfgr 
          order by p_mfgr)); 

select p_mfgr, p_name,  
rank() over (partition by p_mfgr order by p_name) as r, 
dense_rank() over (partition by p_mfgr order by p_name) as dr, 
p_size, sum(p_size) over (partition by p_mfgr order by p_name) as s1 
from noop(on 
        noop(on 
          noop(on 
              noop(on part 
              partition by p_mfgr,p_name 
              order by p_mfgr,p_name) 
            ) 
          partition by p_mfgr 
          order by p_mfgr)); 


-- 21. testMultiOperatorChainEndsWithNoopMap
explain
select p_mfgr, p_name,  
rank() over (partition by p_mfgr,p_name) as r, 
dense_rank() over (partition by p_mfgr,p_name) as dr, 
p_size, sum(p_size) over (partition by p_mfgr,p_name rows between unbounded preceding and current row)  as s1 
from noopwithmap(on 
        noop(on 
          noop(on 
              noop(on part 
              partition by p_mfgr,p_name 
              order by p_mfgr,p_name) 
            ) 
          partition by p_mfgr 
          order by p_mfgr) 
          partition by p_mfgr,p_name 
          order by p_mfgr,p_name); 

select p_mfgr, p_name,  
rank() over (partition by p_mfgr,p_name) as r, 
dense_rank() over (partition by p_mfgr,p_name) as dr, 
p_size, sum(p_size) over (partition by p_mfgr,p_name rows between unbounded preceding and current row)  as s1 
from noopwithmap(on 
        noop(on 
          noop(on 
              noop(on part 
              partition by p_mfgr,p_name 
              order by p_mfgr,p_name) 
            ) 
          partition by p_mfgr 
          order by p_mfgr) 
          partition by p_mfgr,p_name 
          order by p_mfgr,p_name); 

-- 22. testMultiOperatorChainWithDiffPartitionForWindow1
explain
select p_mfgr, p_name,  
rank() over (partition by p_mfgr,p_name order by p_mfgr,p_name) as r, 
dense_rank() over (partition by p_mfgr,p_name order by p_mfgr,p_name) as dr, 
p_size, 
sum(p_size) over (partition by p_mfgr,p_name order by p_mfgr,p_name rows between unbounded preceding and current row) as s1, 
sum(p_size) over (partition by p_mfgr,p_name order by p_mfgr,p_name rows between unbounded preceding and current row)  as s2
from noop(on 
        noopwithmap(on 
              noop(on part 
              partition by p_mfgr, p_name 
              order by p_mfgr, p_name) 
          partition by p_mfgr 
          order by p_mfgr
          )); 

select p_mfgr, p_name,  
rank() over (partition by p_mfgr,p_name order by p_mfgr,p_name) as r, 
dense_rank() over (partition by p_mfgr,p_name order by p_mfgr,p_name) as dr, 
p_size, 
sum(p_size) over (partition by p_mfgr,p_name order by p_mfgr,p_name rows between unbounded preceding and current row) as s1, 
sum(p_size) over (partition by p_mfgr,p_name order by p_mfgr,p_name rows between unbounded preceding and current row)  as s2
from noop(on 
        noopwithmap(on 
              noop(on part 
              partition by p_mfgr, p_name 
              order by p_mfgr, p_name) 
          partition by p_mfgr 
          order by p_mfgr
          )); 

-- 23. testMultiOperatorChainWithDiffPartitionForWindow2
explain
select p_mfgr, p_name,  
rank() over (partition by p_mfgr order by p_name) as r, 
dense_rank() over (partition by p_mfgr order by p_name) as dr, 
p_size, 
sum(p_size) over (partition by p_mfgr order by p_name range between unbounded preceding and current row) as s1, 
sum(p_size) over (partition by p_mfgr order by p_name range between unbounded preceding and current row)  as s2
from noopwithmap(on 
        noop(on 
              noop(on part 
              partition by p_mfgr, p_name 
              order by p_mfgr, p_name) 
          ));

select p_mfgr, p_name,  
rank() over (partition by p_mfgr order by p_name) as r, 
dense_rank() over (partition by p_mfgr order by p_name) as dr, 
p_size, 
sum(p_size) over (partition by p_mfgr order by p_name range between unbounded preceding and current row) as s1, 
sum(p_size) over (partition by p_mfgr order by p_name range between unbounded preceding and current row)  as s2
from noopwithmap(on 
        noop(on 
              noop(on part 
              partition by p_mfgr, p_name 
              order by p_mfgr, p_name) 
          ));
 
