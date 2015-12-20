<h1>Akinator like engine</h1>
<p>A collegue has approached to us with a question on how <a href="http://en.akinator.com/" target="_blank">Akinator</a> engine may work. </p>
<p>To our shame we have never heard about this amazing game before. To fill the gap we have immediately started to play it, and have identified it as a <a href="https://en.wikipedia.org/wiki/Troubleshooting" target="_blank">Troubleshooting</a> solver.</p>
<p>It took us a couple of minutes to come up with a brilliant solution: "We just need to google and find the engine in the internet". :-)</p>
<p>Unfortunately, this led to nowhere, as no Akinator itself is open sourced, and no other good quality open source solutions are available.</p>
<p>After another hour we have got two more ideas:</p>
<ol>
<li>The task should fit into SQL;</li>
<li>The task is a good candidate for a neural network.</li>
</ol>
<p>In fact, the first might be required to teach the second, so we have decided to formalize the problem in terms of SQL, while still keeping in mind a neural network.</p>
<h3>SQL solution</h3>
<p>We have selected SQL Server as a database to implement our solution. A similar implementation is possible in other SQL (DB2, Oracle, MySql, SQLite), or NoSQL databases. SQL Server's facilities have allowed us to implement the task as a pure T-SQL API.</p>
<h4>Concepts</h4>
<p>The task can be defined as:"Guess an <b>entity</b> through a series of <b>predicates</b>".</p>
<p>The database should contain following tables:</p>
<ul>
  <li><code>Entity</code> - to define objects that can be found;</li>
  <li><code>PredicateType</code> - to define questions that can be asked about objects;</li>
  <li><code>Predicate</code> - to relate objects with answers to the questions.</li>
</ul>
<p>These tables is enough to construct an algorithm that takes as input a list of questions with answers, and offers the following question(s), if any (see <a href="#nesterovsky-algorithm-to-suggest-next-question">Algorithm to suggest next question</a>). But before building such an algorithm we must understand how can we populate these tables.</p>
<p>We argued like this:</p>
<ul>
  <li><b>entities</b> have <b>properties</b>;</li>
  <li><b>predicates</b> are based on <b>properties</b> of <b>entities</b>. </li>
</ul>
<p>Having <b>entities</b> with <b>properties</b> we can:</p>
<ul>
  <li>populate <code>Entity</code>;</li>
  <li>mine properties to populate <code>PredicateType</code>;</li>
  <li>populate <code>Predicate</code> based on answers.</li>
</ul>
<p>Thus, the database should also contain following tables:</p>
<ul>
  <li><code>PropertyType</code> - to define different types of properties that entities can have;</li>
  <li><code>Property</code> - to define properties per entity.</li>
</ul>
<h4>Test data</h4>
<p>Samples are required to evaluate the quality of the implementation. It took awhile to find such a data, mainly due to the problem with formulation of the search query. We have found the <a href="http://wiki.dbpedia.org/" target="_blank">DBpedia</a> - <em>a crowd-sourced community effort to extract structured information from Wikipedia and make this information available on the Web.</em> </p>
<p>Many interesting datasets are collected there. We have decided to try <a href="http://web.informatik.uni-mannheim.de/DBpediaAsTables/csv/Person.csv.gz">Person</a> dataset, which we got in cvs format from <a href="http://web.informatik.uni-mannheim.de/DBpediaAsTables/DBpediaClasses.htm" target="_blank">http://web.informatik.uni-mannheim.de/DBpediaAsTables/DBpediaClasses.htm</a>. It contains information for more than 1.5 million persons, with several hundreds of different types of properties.</p>
<p>Through a sequence of simple manipulations (see later in <a href="https://github.com/nesterovsky-bros/KB/tree/master/SQL/Persons">Load Persons</a>) we have imported this cvs into <code>PropertyType</code> and into <code>Property</code> tables.</p>
<h4>Data mining</h4>
<p>At the following stage we looked into data, calculated use counts per each property type, and per property value. This has helped us to formulate several dozen questions about persons, like: "Is he/she living person?", "Is he/she politician?", "Is he/she artist?", "Is he/she writer?", "Is he/she tall?", "Is he a male?".</p>
<p>We have found that there are questions that split whole set of persons into two more or less equal subsets. Other questions subset rather small set of persons. Yet other questions have fuzzy meaning, or are based on impresice property values (e.g. what does it mean "tall", or what to do with property "sex" that is defined not for all persons?)</p>
<p>Looking more closely we can see that questions might be related. Consider that if "Is football player?" is true, then "Is sportsman?" is true also; or if "Was born somewhere in Europe?" is false then "Was born in France?" is also false. One way to represent such relations between questions is through hierarchy:</p>
<ol>
  <li>Is sportsman?
    <ol>
      <li>Is football player?</li>
      <li>...</li>
    </ol>
  </li>
  <li>Was born somewhere in Europe?
    <ol>
      <li>Was born in France?</li>
      <li>...</li>
    </ol>
  </li>
  <li>...</li>
</ol>
<h4>Sql definitions</h4>
<p>Let's define tables.</p>
<p>Table <code>Entity</code> defines objects:</p>
<blockquote><pre>create table Data.Entity
(
  EntityID int not null primary key
);</pre></blockquote>
<p>where</p>
<ul><li><code>EntityID</code> - is an object identity.</li></ul>
<p>Table <code>PredicateType</code> defines predicate types:</p>
<blockquote><pre>create table Data.PredicateType
(
  PredicateID hierarchyid not null primary key,
  Name nvarchar(128) not null unique,
  Expression nvarchar(max) null,
  Computed bit not null default 0,
  ScopePredicateID hierarchyid null,
  Hidden bit not null default 0,
  Imprecise bit not null default 0
);</pre></blockquote>
<p>where</p>
<ul>
  <li><code>PredicateID</code> - hierarchy ID that uniquely defines a predicate type.</li>
  <li><code>Name</code> - a unique predicate name in form: <code>'IsLivingPerson'</code>, <code>'IsMale'</code>, <code>'IsPolitician'</code>. Name can be seen as a question in human readable form.</li>
  <li><code>Expression</code> - an sql source used to evaluate the predicate. Usually it is of the form: <code>Data.Predicate_IsLivingPerson()</code>. If <code>Computed = 0</code> then this source is used to populate <code>Data.Predicate</code> table; otherwise when <code>Computed = 1</code> this source is used every time to get entities that match the predicate.</li>
  <li><code>Computed</code> - indicates whether to store entities that match the predicate in <code>Data.Predicate</code> table (value is <code>0</code>), or to evaluate <code>Expression</code> each time a predicate is requested (value is <code>1</code>).</li>
  <li><code>ScopePredicateID</code> - if specified, then the value defines the scope of <code>PredicateID</code> (e.g. "IsMale", "IsFemale" predicates are defined not for all persons, but only for those having "Sex" property; in this case we define "Sex" preicate, and "IsMale", "IsFemale" refer to "Sex" as a scope).</li>
  <li><code>Hidden</code> - indicates that the predicate should not be offered (value is <code>1</code>).</li>
  <li><code>Imprecise</code> - indicates whether the predicate is not precise, meanning that some irrelevant objects might be matched by the predicates, and some relevant object might be not matched. (E.g. "IsTall" is a imprecise predicate as the answer considerably depends on player. Answer to such a question should always be considered as "probalby")</li>
</ul>
<p>Table <code>Predicate</code> stores entities for which predicate is true:</p>
<blockquote><pre>create table Data.Predicate
(
  PredicateID hierarchyid not null,
  EntityID int not null,
  constraint PK_Predicate primary key clustered(PredicateID, EntityID),
  constraint IX_Predicate_Entity unique(EntityID, PredicateID),
  constraint FK_Predicate_Entity foreign key(EntityID) 
    references Data.Entity(EntityID)
    on update cascade
    on delete cascade
);</pre></blockquote>
<p>where</p>
<ul>
  <li><code>PredicateID</code> - a predicate reference;</li>
  <li><code>EntityID</code> - an entity reference.</li>
</ul>
<p>Table <code>PropertyType</code> defines types of properties:</p>
<blockquote><pre>create table Data.PropertyType
(
  PropertyID int not null constraint PK_PropertyType primary key,
  Name nvarchar(128) not null,
  Type nvarchar(256) not null,
  index IX_PropertyType(Name)
);</pre></blockquote>
<p>where</p>
<ul>
  <li><code>PropertyID</code> - a unique property ID;</li>
  <li><code>Name</code> - a  property name;</li>
  <li><code>Type</code> - a property type.</li>
</ul>
<p>Table Property defines object properties:</p>
<blockquote><pre>create table Data.Property
(
  EntityID int not null,
  PropertyID int not null,
  Value nvarchar(4000) null,
  constraint FK_Property_Entity foreign key(EntityID)
    references Data.Entity(EntityID)
    on update cascade
    on delete cascade,
  index IX_Property_Property clustered(PropertyID, EntityID),
  index IX_Property_Entity(EntityID, PropertyID)
);</pre></blockquote>
<p>where</p>
<ul>
  <li><code>EntityID</code> - is an entity reference;</li>
  <li><code>PropertyID</code> - refers to a preperty type;</li>
  <li><code>Value</code> - a property value.</li>
</ul>
<p>Together we had a heated debate on whether <code>Data.Entity</code> is required at all, 
and if it is required then it might worth to add more info (like name or description) to it.
We have agreed that something like this is required: either table or inexed view based on <code>Data.Property</code> or on <code>Data.Predicate</code> tables. 
In favor of the table decision it says that we can build foreign keys. 
As for additional columns to <code>Data.Entity</code> the argument was that the <code>Data.Property</code> already contains entity properties, and  it is not exactly clear what property should be added directly to <code>Data.Entity</code>.</p>

<h4>Predicate definitions</h4>
<p>A question definition translated into SQL would look like a query against <code>Property</code> table, like the following:</p>
<blockquote><code>select EntityID from Data.Property where PropertyID = @livingPersonPropertID</code></blockquote>
<p>or</p>
<blockquote><code>select EntityID from Data.Property where PropertyID = @sexProperyID and TextValue = 'male'</code></blockquote>
<p>Further, these queries are wrapped into sql functions:</p>
<blockquote><code>select * from Data.Predicate_IsLivingPerson()</code></blockquote>
<p>or</p>
<blockquote><code>select * from Data.Predicate_IsMale()</code></blockquote>
<p>To manage predicates we have defined several simple stored procedures:</p>
<blockquote><pre>-- Defines and populates a predicate
create procedure Data.DefinePredicate
(
  -- A predicate name to define.
  @name nvarchar(128),
  -- A predicate expression.
  @expression nvarchar(max) = null,
  -- Computed indicator
  @computed bit = 0,
  -- Optional parent predicate.
  @parent nvarchar(128) = null,
  -- Optional scope predicate.
  @scope nvarchar(128) = null,
  -- Optional value that indicates that the predicate is hidden.
  @hidden bit = 0,
  -- Indicates whether the predicate lacks accuracy. Default is 0.
  @imprecise bit = 0,
  -- 1 (default) to populate the predicate immediately.
  @populate bit = 1
);

-- Deletes a predicate.
create procedure Data.DeletePredicate
(
  -- A predicate name to define.
  @name nvarchar(128) = null
);

-- Invalidates a predicate.
create procedure Data.InvalidatePredicate
(
  -- A predicate name.
  @name nvarchar(128) = null
);

-- Invalidates all predicates.
create procedure Data.InvalidatePredicates();</pre></blockquote>
<p>and a couple of utility functions:</p>
<blockquote><pre>create function Data.GetPropertyID(@name nvarchar(128))
returns int
as
begin
  return (select PropertyID from Data.PropertyType where Name = @name);
end;

create function Data.GetPredicateID(@name nvarchar(128))
returns hierarchyid
as
begin
  return (select PredicateID from Data.PredicateType where Name = @name);
end;</pre></blockquote>
<p>Now, when you want to define a new predicate, you follow these steps:</p>
<ul><li>Define a predicate function that returns a set of entities that apply to a question, like this:</li></ul>
<blockquote><pre>create function Data.Predicate_IsActor()
returns table
as
return
  select
    EntityID
  from 
    Data.Property
  where 
    (PropertyID = Data.GetPropertyID('22-rdf-syntax-ns#type_label')) and
    (TextValue = 'actor');</pre></blockquote>
<ul><li>Define a predicate like this:</li></ul>
<blockquote><pre>execute Data.DefinePredicate
  @name = 'IsActor', 
  @expression = 'Data.Predicate_IsActor()';</pre></blockquote>
<p>While you are experimenting with questions you might want to reformulate the question, or delete the question. So to delete the question you call:</p>
<blockquote><pre>execute Data.DeletePredicate @name = 'IsActor'</pre></blockquote>
<p>To invalidate predicate (delete and repopulate relevant data into <code>Data.Predicate</code> table) you call:</p>
<blockquote><pre>execute Data.InvalidatePredicate @name = 'IsActor'</pre></blockquote>
<p>To invalidate all predicates (delete and repopulate all data into <code>Data.Predicate</code> table) you call:</p>
<blockquote><pre>execute Data.InvalidatePredicates</pre></blockquote>
<h4 name="nesterovsky-algorithm-to-suggest-next-question">Algorithm to suggest next questions</h4>
<p>Core algorithm spins around <code>Predicate</code>, <code>Entity</code>, and <code>PredicateType</code> tables.</p>
<p>Assuming we have <code>P(i)</code> - predicates, and <code>A(i)</code> - answers, where <code>i = 1..n</code>; let answer <code>A(i)</code> be <code>0</code> for "no", and <code>1</code> for "yes". We are going to build a select that returns next predicates.</p>
<p>The initial part of select gets subsets of entities that match the predicates:</p>
<blockquote><pre>with P1 as -- P(1)
(
  select EntityID from Data.Predicate where PredicateID = @p1
),
P2 as -- P(2)
(
  select EntityID from Data.Predicate where PredicateID = @p2
),
...
Pn as -- P(n)
(
  select EntityID from Data.Predicate where PredicateID = @pn
),</pre></blockquote>
<p>at the next step we get entities that are matched by those predicates:</p>
<blockquote><pre>M as
(
  select EntityID from Data.Entity

  -- Intersect those Pi that has A(i) = 1
  intersect
  select EntityID from Pi -- where A(i) = 1
  ...

  -- Except those Pj that has A(j) = 0
  except
  select EntityID from Pj -- where A(j) = 0
  ...
),</pre></blockquote>
<p>Now, we can query predicates for matched entities, except those predicates that has been already used:</p>
<blockquote><pre>P as
(
  select
    P.PredicateID,
    count(*) EntityCount,
    (select count(*) from M) TotalCount 
  from
    Data.Predicate P
    inner join
    M
    on
      P.EntityID = M.EntityID
  where
    P.PredicateID not in (@p1, @p2, ..., @pn)
  group by
    P.PredicateID
)</pre></blockquote>
<p>where</p>
<ul>
  <li><code>EntityCount</code> - is number of entities that match a specified predicate;</li>
  <li><code>TotalCount</code> - a total number of entities that match input predicates.</li>
</ul>
<p>As a final result we can return first several predicates that split set of entities more evenly:</p>
<blockquote><pre>select top(5) * from P order by abs(TotalCount - EntityCount * 2);</pre></blockquote>
<p>For example, if we have <code>n = 5</code>, and <code>A(1) = A(3) = 1, A(2) = A(4) = A(5) = 0</code> then the select will look like this:</p>
<blockquote><pre>with P1 as -- P(1), A(1) = 1
(
  select EntityID from Data.Predicate where PredicateID = @p1
),
P2 as -- P(2), A(2) = 0
(
  select EntityID from Data.Predicate where PredicateID = @p2
),
P3 as -- P(3), A(3) = 1
(
  select EntityID from Data.Predicate where PredicateID = @p3
),
P4 as -- P(4), A(4) = 0
(
  select EntityID from Data.Predicate where PredicateID = @p4
),
P5 as -- P(5), A(5) = 0
(
  select EntityID from Data.Predicate where PredicateID = @p5
),
M as
(
  select EntityID from Data.Entity
  intersect
  select EntityID from P1
  intersect
  select EntityID from P3
  except
  select EntityID from P2
  except
  select EntityID from P4
  except
  select EntityID from P5
),
P as
(
  select
    P.PredicateID,
    count(*) EntityCount,
    (select count(*) from M) TotalCount
  from
    Data.Predicate P
    inner join
    M
    on
      P.EntityID = M.EntityID
  where
    P.PredicateID not in (@p1, @p2, @p3, @p4, @p5)
  group by
    P.PredicateID
)
select top(5) * from P order by abs(TotalCount - EntityCount * 2);</pre></blockquote>
<p>Now, let's complicate the task, and assume fuzzy answers:</p>
<ul>
  <li><code>0</code> - for "no";</li>
  <li><code>(0, 0.5)</code> - for "probably no";</li>
  <li><code>0.5</code> - for "don't know";</li>
  <li><code>(0.5, 1)</code> - for "probably yes";</li>
  <li><code>1</code> - for "yes".</li>
</ul>
<p>Fuzzy answers should not cut subsets of entities but prioritize order of predicates returned.</p>
<p>Lets's start from "don't know" answer. In this case we should equally accept both subsets of entities that match and that don't match the predicate. The only impact on result from such answer is that the relevant predicate is excluded from the next offers.</p>
<p>So, lets assume in the previous exmaple that we have <code>n = 5</code>, and <code>A(1) = 1, A(3) = 0.5, A(2) = A(4) = A(5) = 0</code> then the select will look like this:</p>
<p>The result select will look like this:</p>
<blockquote><pre>with P1 as -- P(1), A(1) = 1
(
  select EntityID from Data.Predicate where PredicateID = @p1
),
P2 as -- P(2), A(2) = 0
(
  select EntityID from Data.Predicate where PredicateID = @p2
),
P3 as -- P(3), A(3) = 0.5
(
  select EntityID from Data.Predicate where PredicateID = @p3
),
P4 as -- P(4), A(4) = 0
(
  select EntityID from Data.Predicate where PredicateID = @p4
),
P5 as -- P(5), A(5) = 0
(
  select EntityID from Data.Predicate where PredicateID = @p5
),
M as
(
  select EntityID from Data.Entity
  intersect
  select EntityID from P1
-- intersect
-- select EntityID from P3
  except
  select EntityID from P2
  except
  select EntityID from P4
  except
  select EntityID from P5
),
P as
(
  select
    P.PredicateID,
    count(*) EntityCount,
    (select count(*) from M) TotalCount
  from
    Data.Predicate P
    inner join
    M
    on
      P.EntityID = M.EntityID
  where
    P.PredicateID not in (@p1, @p2, @p3, @p4, @p5)
  group by
    P.PredicateID
)
select top(5) * from P order by abs(TotalCount - EntityCount * 2);</pre></blockquote>
<p>Notice that <code>P3</code> is not used in <code>M</code>.</p>
<p>The final step is to account "probably" answers. Such answers give weight to each entity. Offered predicates should be ordered according to weight of entities they are based on.</p>
<p>Assuming we have <code>P(i)</code> - predicates, and <code>A(i)</code> - answers, where <code>i = 1..n</code>; and assume that A(k), and A(l) have "probably" answers. In this case let's define weighted entities:</p>
<blockquote><pre>E as
(
  select
    EntityID,
    iif(EntityID in (select EntityID from Pk), @ak, 1 - @ak) *
      iif(EntityID in (select EntityID from Pl), @al, 1 - @al) Weight
  from
    M
),</pre></blockquote>
<p>where</p>
<ul><li><code>Weight</code> - an entity weight.</li></ul>
<p>Now, the query for next predicates can be written like this:</p>
<blockquote><pre>P as
(
  select distinct
    E.Weight,
    P.PredicateID, 
    count(*) over(partition by E.Weight, P.PredicateID) EntityCount,
    count(*) over(partition by E.Weight) TotalCount
  from
    Data.Predicate P
    inner join
    E
    on
      P.EntityID = E.EntityID
  where
    P.PredicateID not in (@p1, @p2, ..., @pn)
)</pre></blockquote>
<p>where</p>
<ul>
  <li><code>Weight</code> - a predicate weight.</li>
  <li><code>EntityCount</code> - is number of entities that match a specified predicate per weight;</li>
  <li><code>TotalCount</code> - a total number of entities that match input predicates per weight.</li>
</ul>
<p>The final result will be almost the same as earlier but ordered at first by weight:</p>
<blockquote><pre>select top(5) * from P order by Weight desc, abs(TotalCount - EntityCount * 2);</pre></blockquote>
<p>So, lets assume in our previous exmaple that we have <code>n = 5</code>, and <code>A(1) = 1, A(3) = 0.5, A(2) = 0, A(4) = 0.3, A(5) = 0.8</code> then the select will look like this:</p>
<blockquote><pre>with P1 as -- P(1), A(1) = 1
(
  select EntityID from Data.Predicate where PredicateID = @p1
),
P2 as -- P(2), A(2) = 0
(
  select EntityID from Data.Predicate where PredicateID = @p2
),
P3 as -- P(3), A(3) = 0.5
(
  select EntityID from Data.Predicate where PredicateID = @p3
),
P4 as -- P(4), A(4) = 0.3
(
  select EntityID from Data.Predicate where PredicateID = @p4
),
P5 as -- P(5), A(5) = 0.8
(
  select EntityID from Data.Predicate where PredicateID = @p5
),
M as
(
  select EntityID from Data.Entity
  intersect
  select EntityID from P1
-- intersect
-- select EntityID from P3
  except
  select EntityID from P2
-- except
-- select EntityID from P4
-- except
-- select EntityID from P5
),
E as
(
  select
    EntityID,
    iif(EntityID in (select EntityID from P4), 0.3, 0.7) *
      iif(EntityID in (select EntityID from P5), 0.8, 0.2) Weight
  from
    M
),
P as
(
  select distinct
    E.Weight,
    P.PredicateID, 
    count(*) over(partition by E.Weight, P.PredicateID) EntityCount,
    count(*) over(partition by E.Weight) TotalCount
  from
    Data.Predicate P
    inner join
    E
    on
      P.EntityID = E.EntityID
  where
    P.PredicateID not in (@p1, @p2, @p3, @p4, @p5)
)
select top(5) * from P order by Weight desc, abs(TotalCount - EntityCount * 2);</pre></blockquote>
<p>That is the most complex form of select that algorithm should produce.</p>
<p>Consider now results of these selects.</p>
<p>If there are rows in result set, then we can either offer predicate from the first row, or, if we want to model some randomness, we can at times go to some other predicate from those returned. </p>
<p>If no rows are returned then we are finished with offers. The only thing we can return is a set of matched entities that is:</p>
<blockquote><pre>select * from M;</pre></blockquote>
<p>or in case or "probably" answers:</p>
<blockquote><pre>select * from E;</pre></blockquote>
<p>We might want to join those selects with <code>Data.Property</code> table to bring some entity properties, like name, or description.</p>
<h4>Implementation of algorithm</h4>
<p>Now algorithm is clear. The deal is just to implement it. We can see that the structure of select depends considerably on number of questions and type of answers. </p>
<p>To deal with this we use dynamic SQL. In the past we wrote an article on "<a href="http://www.nesterovsky-bros.com/weblog/2014/02/11/DealingWithDynamicSQLInSQLServer.aspx" target="_blank">Dealing with dynamic SQL in SQL Server</a>".</p>
<p>The idea was to use XQuery as a SQL template language. At first you might think that this is too radical step but after a close look you will observe that it might be the most straightforward solution to deal with dynamic SQL. Just consider an XQuery snapshot that builds <code>"Pi as (...), ..."</code> text:</p>
<blockquote><pre>'&lt;sql>with &lt;/sql>,

for $predicate in $predicates
let $row := xs:integer($predicate/@Row)
let $predicateID := xs:string($predicate/@PredicateID)
let $name := xs:string($predicate/@Name)
return
  &lt;sql>P{$row} as -- &lt;name>{$name}&lt;/name>
(
  select EntityID from Data.Predicate where PredicateID = &lt;string>{$predicateID}&lt;/string>
),
&lt;/sql>'</pre></blockquote>
<p>We have defined two SQL functions that build SQL text for such input xml:</p>
<blockquote><pre>create function Dynamic.GetSQL_GetNextPredicate
(
  -- Request parameters.
  @params xml
);

create function Dynamic.GetSQL_GetEntities
(
  -- Request parameters.
  @params xml,
  -- Optional property value to return.
  @property nvarchar(128)
);</pre></blockquote>
<p>and two more stored procedures one that offers new predicates, and the other that returns matched entities:</p>
<blockquote><pre>-- Gets next predicates
create procedure Data.GetNextPredicates
(
  -- Request parameters.
  @params xml,
  -- Result as a predicate
  @result xml output
);

-- Gets entities for predicates
create procedure Data.GetEntities
(
  -- Request parameters.
  @params xml,
  -- Optional property value to return.
  @property nvarchar(128)
);</pre></blockquote>
<p>The input for these procedures are in the form of xml like this:</p>
<blockquote><pre>&lt;request>
  &lt;question name="IsLivingPerson" answer="1"/>
  &lt;question name="IsFootballPlayer" answer="0"/>
  &lt;question name="IsArtist" answer="0.3"/>
  ...
&lt;request>
</pre></blockquote>
<p><code>Data.GetNextPredicates</code> returns an xml result fragment with next suggested predicates in the form:</p>
<blockquote><pre>&lt;question name="IsPolitician"/>
&lt;question name="IsReligious"/>
&lt;question name="IsMilitary"/>
</pre></blockquote>
<p><code>Data.GetEntities</code> returns a set of entities with possible value of some property (like name or description).</p>
<h4>Cache of results</h4>
<p>At this point we could complete our explanation of the algorithm and its implementation, especially taking into account that performance over test data, which is more than 1.5 million of entities, is very good. Indeed, it take 100ms on average to build SQL, and from dozens milliseconds and up to 3 - 4 seconds to run the query. Execution plans look good, and there are no bottlenecks for scalability.</p>
<p>But we have thought that we can do better! According to the algorithm there are just several best predicates on the top level; there are also not too many best predicates on the second level, and so on. We have estimated that we can cache different results for all requests, say, for up to ten or even more input predicates. This means that we can immediately give answers to different sets of inputs, and descend to a rather small set of remaining entities. On the remaining set, a regular, even non-cached, search works very fast.</p>
<p>So, we will continue.</p>
<h4>Caching implementation</h4>
<p>We cache search offers in a tree. Each node in this tree:
<ul>
  <li>has a node identifier;</li>
  <li>refers to the parent node (parent offer); and</li>
  <li>is classified with answer to the parent offer, and with new offered predicate.</li>
</ul>
<p>Path from any specific node to the root of the tree defines a set of questions and answers, and the node itself offers next predicate.</p>
<p>This way cache table can be defined like this:</p>
<blockquote><pre>create table Data.PredicateTree
(
  ID int not null primary key,
  ParentID int not null,
  Answer decimal(2, 1) not null,
  PredicateID hierarchyid null,
  Populated bit not null default 0,
  constraint IX_PredicateTree unique(ParentID, Answer, PredicateID)
);</pre></blockquote>
<p>where</p>
<ul>
  <li><code>ID</code> - a node identifier.</li>
  <li><code>ParentID</code> - reference to a parent node.</li>
  <li><code>Answer</code> - answer to the parent offer.</li>
  <li><code>PredicateID</code> - offered predicate; when value is null then this search brings no next predicate.</li>
  <li><code>Populated</code> - indicates whether it is a populated search result (1), or it is a row inserted to populate a descendant search result.</li>
</ul>
<h4>How caching works</h4>
<p>Caching is integrated into the procedure <code>Data.GetNextPredicates</code>.</p>
<ol>
  <li>When the <code>GetNextPredicates</code> is called, request's questions are sorted by <code>PredicateID</code>. This is to reduce a number of permutations to store in the cache. This can be done, as an offer does not depend on order of questions but on whole set of questions only.</li>
  <li><code>PredicateTree</code> is checked to find a node that corresponds requested questions with answers.</li>
  <li>If such node is found then offered predicates are returned.</li>
  <li>Otherwise regular search is done, and results are cached into the <code>PredicateTree</code>.</li>
</ol>
<h4>Decision Tree</h4>
<p>If you will look at caching from the other perspective, and will decide to cache all data in such tree, then it can be qualified as a decition tree. The data contained in such table will be enough to guess any person.</p>
<h4>Play the search</h4>
<p>We can guess a specific entity and start playing executing <code>Data.GetNextPredicates</code> iteratively and answering offered questions.</p>
<p>This way we shall reach to the point where no more predicates are offered. This way procedures either localized a minimal subset of entities or found required entity itself.</p>
<p>We have defined a procedure <code>Data.PlaySearch</code> that does exactly this. It plays the game. Among other roles this procedure populates the search cache.</p>
<h4>Sources</h4>
<p>Solution sources are published at <a href="https://github.com/nesterovsky-bros/KB">github.com/nesterovsky-bros/KB</a>.</p>
<p>SQL Server scripts are found at <a href="https://github.com/nesterovsky-bros/KB/SQL">github.com/nesterovsky-bros/KB/SQL</a>.</p>
<p>Steps to load DBpedia Persons data are described at <a href="https://github.com/nesterovsky-bros/KB/SQL/Persons">github.com/nesterovsky-bros/KB/SQL/Persons</a>.</p>
<p>Thank you for your attention.</p>
