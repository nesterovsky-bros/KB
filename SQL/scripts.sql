-- Simplest form of create database statement.
-- CREATE DATABASE KB;
-- USE KB;

CREATE SCHEMA [Data]
GO
CREATE SCHEMA [Dynamic]
GO
CREATE SCHEMA [Metadata]
GO
CREATE XML SCHEMA COLLECTION [Data].[XmlTypes] AS N'<xsd:schema xmlns:xsd="http://www.w3.org/2001/XMLSchema"><xsd:element name="question" type="question" /><xsd:element name="request" type="request" /><xsd:complexType name="question"><xsd:complexContent><xsd:restriction base="xsd:anyType"><xsd:sequence /><xsd:attribute name="name" type="xsd:string" /><xsd:attribute name="answer" type="xsd:decimal" /></xsd:restriction></xsd:complexContent></xsd:complexType><xsd:complexType name="request"><xsd:complexContent><xsd:restriction base="xsd:anyType"><xsd:choice minOccurs="0" maxOccurs="unbounded"><xsd:element ref="question" /></xsd:choice></xsd:restriction></xsd:complexContent></xsd:complexType></xsd:schema>'
GO

CREATE SEQUENCE [Data].[EntityID] AS [int] START WITH 1
GO

CREATE SEQUENCE [Data].[PropertyID] AS [int] START WITH 1
GO

CREATE SEQUENCE [Data].[PredicateTreeID] AS [int] START WITH 1
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [Data].[GetPredicateID]
(
  @name nvarchar(128)
)
returns hierarchyid
as
begin
  return
  (
    select 
      PredicateID
    from
      Data.PredicateType
    where
      Name = @name
  );
end

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [Data].[GetPropertyID]
(
  @name nvarchar(128)
)
returns int
as
begin
  return
  (
    select 
      PropertyID
    from
      Data.PropertyType
    where
      Name = @name
  );
end
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [Dynamic].[GetSQL_GetEntities]
(
  -- Request parameters.
  @params xml,
  -- Number of rows to return
  @take int,
  -- Optional property value to return.
  @property nvarchar(128)
)
returns nvarchar(max)
as
begin
  declare @sql nvarchar(max);
 
  with Data as
  (
    select cast(isnull(@params, '<request/>') as xml(document Data.XmlTypes)) Data
  ),
  Predicate as
  (
    select
      row_number() over(order by Node) Row,
      P.PredicateID,
      P.Name,
      P.ScopePredicateID,
      (
        select
          S.Expression
        from
          Data.PredicateType S with(forceseek)
        where
          (S.PredicateID = P.ScopePredicateID) and
          (S.Computed = 1)
      ) ScopeExpression,
      iif(P.Computed = 1, P.Expression, null) Expression,
      case when P.Imprecise = 1
        then cast(Q.Answer * 0.8 + 0.1 as decimal(2, 1))
        else Q.Answer
      end Answer
    from
      Data
      cross apply
      Data.nodes('/request/*') N(Node)
      inner loop join
      Data.PredicateType P
      on
        P.Name = Node.value('self::question/@name', 'nvarchar(128)')
      cross apply
      (select Node.value('self::question/@answer', 'decimal(2, 1)') Answer) Q
  ),
  Params as
  (
    select
      @take Take,
      (
        select top 1
          PropertyID
        from
          Data.PropertyType
        where
          Name = @property
      ) PropertyID,
      (
        select
          *
        from
          Predicate
        order by
          Row
        for xml auto, type
      ) Predicates
  )
  select 
    @sql = Dynamic.ToSQL(isnull(Predicates, '<Null/>').query(N'
let $take := xs:integer(sql:column("Take"))
let $propertyID := xs:integer(sql:column("PropertyID"))
let $predicates := Predicate
let $positivePredicates := $predicates[xs:decimal(@Answer) = 1]
let $negativePredicates := $predicates[xs:decimal(@Answer) = 0]
let $otherPredicates := $predicates[not(xs:decimal(@Answer) = (0, 0.5, 1))]
return
(
  <sql>with </sql>,

  for $predicate in $predicates
  let $row := xs:integer($predicate/@Row)
  let $predicateID := xs:string($predicate/@PredicateID)
  let $name := xs:string($predicate/@Name)
  let $expression := xs:string($predicate/@Expression)
  let $answer := xs:decimal($predicate/@Answer)
  let $scopePredicateID := xs:string($predicate/@ScopePredicateID)
  let $scopeExpression := xs:string($predicate/@ScopeExpression)
  return
  (
    <sql>P{$row} as -- <name>{$name}</name>
(
  </sql>,
   
    if (empty($expression) or ($expression = "")) then
    (
      <sql>select EntityID from Data.Predicate with(forceseek) where PredicateID = <string>{$predicateID}</string></sql>
    )
    else
    (
      <sql>select EntityID from {$expression}</sql>
    ),

    if (not(empty($scopePredicateID)) and ($answer = 1)) then
    (
      <sql>
  union all
  (
    select EntityID from Data.Entity
    except
    select EntityID from </sql>,

      if (empty($scopeExpression) or ($scopeExpression = "")) then
      (
        <sql>Data.Predicate with(forceseek) where PredicateID = <string>{$scopePredicateID}</string></sql>
      )
      else
      (
        <sql>{$scopeExpression}</sql>
      ),
      
      <sql>
  )</sql>
    )
    else
    (),

  <sql>
),
</sql>
  ),
  
  <sql>M as
(
  </sql>,
  
  if (empty($positivePredicates)) then
  (
    <sql>select EntityID from Data.Entity</sql>
  )
  else
  (
    let $firstRow := xs:integer($positivePredicates[1]/@Row)
    for $predicate in $positivePredicates
    let $row := xs:integer($predicate/@Row)
    return
    (
      if ($row != $firstRow) then
      (
        <sql>
  intersect
  </sql>
      )
      else 
      (),

      <sql>select EntityID from P{$row}</sql>
    )
  ),

  for $predicate in $negativePredicates
  let $row := xs:integer($predicate/@Row)
  return
  (
    <sql>
  except
  select EntityID from P{$row}</sql>
  ),

  <sql>
),</sql>,


  if (empty($otherPredicates)) then
  (
    <sql>
E as
(
  select 1 W, EntityID from M
)</sql>
  )
  else
  (
    <sql>
E as
(
  select
    </sql>,

    let $lastRow := xs:integer($otherPredicates[last()]/@Row)
    for $predicate in $otherPredicates
    let $row := xs:integer($predicate/@Row)
    let $answer := xs:decimal($predicate/@Answer)
    return
    (
      <sql>iif(EntityID in (select EntityID from P{$row}), <decimal>{$answer}</decimal>, <decimal>{1 - $answer}</decimal>)</sql>,

      if ($row = $lastRow) then
      ()
      else
      (
        <sql> *
      </sql>
      )
    ),

    <sql> W,
    EntityID
  from 
    M
)</sql>
  ),

  <sql>,
C as
(
  select min(W) W from E
)
select</sql>,

if (empty($take)) then
()
else
(
  <sql> top (<int>{$take}</int>)</sql>
),

<sql>
  E.EntityID,
  {
    if (empty($propertyID)) then
    (
      <sql>null Value</sql>
    )
    else
    (
      <sql>P.Value</sql>
    )
  }
from
  E
  inner join
  C
  on
    E.W = C.W
  </sql>,

if (empty($propertyID)) then
()
else
(
  <sql>left join
  Data.Property P
  on
    (P.EntityID = E.EntityID) and
    (P.PropertyID = <int>{$propertyID}</int>)</sql>
),

<sql>
order by 
  Value, 
  E.EntityID
</sql>)'))
  from
    Params;

  return @sql;
end;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [Dynamic].[GetSQL_GetNextPredicate]
(
  -- Request parameters.
  @params xml
)
returns nvarchar(max)
as
begin
  declare @sql nvarchar(max);
 
  with Data as
  (
    select cast(isnull(@params, '<request/>') as xml(document Data.XmlTypes)) Data
  ),
  Predicate as
  (
    select
      row_number() over(order by Node) Row,
      P.PredicateID,
      P.Name,
      (
        select top 1
          1
        from
          Data.PredicateType A with(forceseek)
        where
          (P.PredicateID != A.PredicateID) and
          (P.PredicateID.IsDescendantOf(A.PredicateID) = 1) and
          (A.Hidden = 0)
      ) HasAncestors,
      (
        select top 1
          1
        from
          Data.PredicateType D with(forceseek)
        where
          (P.PredicateID != D.PredicateID) and
          (D.PredicateID.IsDescendantOf(P.PredicateID) = 1) and
          (D.Hidden = 0)
      ) HasDescendants,
      P.ScopePredicateID,
      (
        select
          S.Expression
        from
          Data.PredicateType S with(forceseek)
        where
          (S.PredicateID = P.ScopePredicateID) and
          (S.Computed = 1)
      ) ScopeExpression,
      iif(P.Computed = 1, P.Expression, null) Expression,
      case when P.Imprecise = 1
        then cast(Q.Answer * 0.8 + 0.1 as decimal(2, 1))
        else Q.Answer
      end Answer
    from
      Data
      cross apply
      Data.nodes('/request/*') N(Node)
      inner loop join
      Data.PredicateType P
      on
        P.Name = Node.value('self::question/@name', 'nvarchar(128)')
      cross apply
      (select Node.value('self::question/@answer', 'decimal(2, 1)') Answer) Q
  ),
  Params as
  (
    select
      (
        select
          *
        from
          Predicate
        order by
          Row
        for xml auto, type
      ) Predicates
  )
  select 
    @sql = Dynamic.ToSQL(isnull(Predicates, '<Null/>').query(N'
let $predicates := Predicate
let $positivePredicates := $predicates[xs:decimal(@Answer) = 1]
let $negativePredicates := $predicates[xs:decimal(@Answer) = 0]
let $otherPredicates := $predicates[not(xs:decimal(@Answer) = (0, 0.5, 1))]
return
(
  <sql>with </sql>,

  for $predicate in $predicates
  let $row := xs:integer($predicate/@Row)
  let $predicateID := xs:string($predicate/@PredicateID)
  let $name := xs:string($predicate/@Name)
  let $expression := xs:string($predicate/@Expression)
  let $answer := xs:decimal($predicate/@Answer)
  let $scopePredicateID := xs:string($predicate/@ScopePredicateID)
  let $scopeExpression := xs:string($predicate/@ScopeExpression)
  return
  (
    <sql>P{$row} as -- <name>{$name}</name>
(
  </sql>,
   
    if (empty($expression) or ($expression = "")) then
    (
      <sql>select EntityID from Data.Predicate with(forceseek) where PredicateID = <string>{$predicateID}</string></sql>
    )
    else
    (
      <sql>select EntityID from {$expression}</sql>
    ),

    if (not(empty($scopePredicateID)) and ($answer = 1)) then
    (
      <sql>
  union all
  (
    select EntityID from Data.Entity
    except
    select EntityID from </sql>,

      if (empty($scopeExpression) or ($scopeExpression = "")) then
      (
        <sql>Data.Predicate with(forceseek) where PredicateID = <string>{$scopePredicateID}</string></sql>
      )
      else
      (
        <sql>{$scopeExpression}</sql>
      ),
      
      <sql>
  )</sql>
    )
    else
    (),

  <sql>
),
</sql>
  ),
  
  <sql>M as
(
  </sql>,
  
  if ($positivePredicates) then
  (
    let $firstRow := xs:integer($positivePredicates[1]/@Row)
    for $predicate in $positivePredicates
    let $row := xs:integer($predicate/@Row)
    return
    (
      if ($row != $firstRow) then
      (
        <sql>
  intersect
  </sql>
      )
      else 
      (),

      <sql>select EntityID from P{$row}</sql>
    )
  )
  else if ($otherPredicates or empty($negativePredicates)) then
  (
    <sql>select EntityID from Data.Entity</sql>
  )
  else
  (),

  if ($positivePredicates or $otherPredicates or empty($negativePredicates)) then
  (
    for $predicate in $negativePredicates
    let $row := xs:integer($predicate/@Row)
    return
    (
      <sql>
  except
  select EntityID from P{$row}</sql>
    )
  )
  else
  (
    let $firstRow := xs:integer($negativePredicates[1]/@Row)
    for $predicate in $negativePredicates
    let $row := xs:integer($predicate/@Row)
    return
    (
      if ($row != $firstRow) then
      (
        <sql>
  union
  </sql>
      )
      else
      (),

      <sql>select EntityID from P{$row}</sql>
    )
  ),

  <sql>
),</sql>,


  if (empty($otherPredicates)) then
  (
    <sql>
P as
(
  select
    1 W,
    P.PredicateID, 
    count(*) C,
    </sql>,
    
    if ($positivePredicates or empty($negativePredicates)) then
    (
      <sql>(select count(*) from M)</sql>
    )
    else
    (
      (:<sql>(select count(*) from Data.Entity) - (select count(*) from M)</sql>:)
      <sql>(select EntityCount from Data.Entities with(noexpand)) - (select count(*) from M)</sql>
    ),
    
    <sql> TC
  from
    </sql>
  )
  else
  (
    <sql>
E as
(
  select
    </sql>,

    let $lastRow := xs:integer($otherPredicates[last()]/@Row)
    for $predicate in $otherPredicates
    let $row := xs:integer($predicate/@Row)
    let $answer := xs:decimal($predicate/@Answer)
    return
    (
      <sql>iif(EntityID in (select EntityID from P{$row}), <decimal>{$answer}</decimal>, <decimal>{1 - $answer}</decimal>)</sql>,

      if ($row = $lastRow) then
      ()
      else
      (
        <sql> *
      </sql>
      )
    ),

    <sql> W,
    EntityID
  from 
    M
),
P as
(
  select distinct
    E.W,
    P.PredicateID, 
    count(*) over(partition by E.W, P.PredicateID) C,
    count(*) over(partition by E.W) TC
  from
    </sql>
  ),

<sql>Data.Predicate P</sql>,

  if ($positivePredicates) then
  (
    <sql> with(forceseek, index(IX_Predicate_Entity))</sql>
  )
  else if ($negativePredicates or $otherPredicates) then
  (
    <sql> with(forceseek)</sql>
  )
  else
  (),

  if ($otherPredicates) then
  (
    <sql>
    inner join
    E
    on
      P.EntityID = E.EntityID</sql>
  )
  else
  (),
  
  <sql>
  where
    (P.PredicateID in (select PredicateID from Data.PredicateType where Hidden = 0))</sql>,

  if ($otherPredicates) then
  ()
  else if ($positivePredicates) then
  (
    <sql> and
    (P.EntityID in (select EntityID from M))</sql>
  )
  else
  (
    for $predicate in $negativePredicates
    let $row := xs:integer($predicate/@Row)
    return
    (
      <sql> and 
    (P.EntityID not in (select EntityID from P{$row}))</sql>
    )
  ),

  for $predicate in $predicates
  let $predicateID := xs:string($predicate/@PredicateID)
  let $hasDescendants := xs:boolean($predicate/@HasDescendants)
  let $hasAncestors := xs:boolean($predicate/@HasAncestors)
  let $answer := xs:decimal($predicate/@Answer)
  return
  (
    if (($answer = 1) and $hasAncestors) then
    (
      <sql> and
    (cast(<string>{$predicateID}</string> as hierarchyid).IsDescendantOf(P.PredicateID) = 0)</sql>
    )
    else if (($answer = 0) and $hasDescendants) then
    (
      <sql> and
    (P.PredicateID.IsDescendantOf(<string>{$predicateID}</string>) = 0)</sql>
    )
    else
    (
      <sql> and
    (P.PredicateID != <string>{$predicateID}</string>)</sql>
    )
  ),

  if ($otherPredicates) then
  ()
  else
  (
    <sql>
  group by
    P.PredicateID</sql>
  ),
    
  <sql>
),
R as
(
  select
    W Weight,
    cast(abs(1 - 2.0 * C / TC) as decimal(2, 1)) Deviation,
    PredicateID
  from
    P
)
</sql>)'))
  from
    Params;
 
  return @sql;
end;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Builds a text of SQL function for an sql template. 
CREATE function [Dynamic].[ToSQL] 
( 
  -- SQL template. 
  -- Following is the xml schema of the template: 
  /* 
<xs:schema elementFormDefault="qualified" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema">;

  <xs:element name="base" abstract="true">
    <xs:annotation>
      <xs:documentation>A base element.</xs:documentation>
    </xs:annotation>
  </xs:element>

  <xs:element name="sql" substitutionGroup="base" nillable="false">
    <xs:annotation>
      <xs:documentation>An SQL content.</xs:documentation>
    </xs:annotation>

    <xs:complexType mixed="true">
      <xs:sequence>
        <xs:element ref="base" minOccurs="0" maxOccurs="unbounded"/>
      </xs:sequence>
    </xs:complexType>
  </xs:element>

  <xs:element name="name" substitutionGroup="base" nillable="false">
    <xs:annotation>
      <xs:documentation>
        A quoted name.
      </xs:documentation>
    </xs:annotation>
  </xs:element>

  <xs:element name="strint" substitutionGroup="base" nillable="false">
    <xs:annotation>
      <xs:documentation>
        A string literal.
      </xs:documentation>
    </xs:annotation>
  </xs:element>
 
  <xs:element name="fulltext" substitutionGroup="base" nillable="false">
    <xs:annotation>
      <xs:documentation>
        A fulltext string literal.
      </xs:documentation>
    </xs:annotation>
  </xs:element>

  <xs:element name="int" substitutionGroup="base" nillable="true">
    <xs:annotation>
      <xs:documentation>
        An int value.
      </xs:documentation>
    </xs:annotation>
  </xs:element>

  <xs:element name="decimal" substitutionGroup="base" nillable="true">
    <xs:annotation>
      <xs:documentation>
        A decimal value.
      </xs:documentation>
    </xs:annotation>
  </xs:element>

  <xs:element name="date" substitutionGroup="base" nillable="true">
    <xs:annotation>
      <xs:documentation>
        A date value.
      </xs:documentation>
    </xs:annotation>
  </xs:element>

  <xs:element name="time" substitutionGroup="base" nillable="true">
    <xs:annotation>
      <xs:documentation>
        A time value.
      </xs:documentation>
    </xs:annotation>
  </xs:element>

  <xs:element name="datetime" substitutionGroup="base" nillable="true">
    <xs:annotation>
      <xs:documentation>
        A dateTime value.
      </xs:documentation>
    </xs:annotation>
  </xs:element>

</xs:schema>
  */ 
  @template xml 
) 
returns nvarchar(max) 
with returns null on null input
as 
begin
  return isnull
  (
    (
      select
        case 
          when Name = '' then Value
          when Name = 'name' then quotename(Value, '[')
          when Nil = 1 then 'null'
          when 
            (Name = 'int') and 
            (try_convert(int, Value) is not null) 
          then
            Value
          when Name = 'string' then
            'N''' + replace(Value, '''',  '''''') + ''''
          when 
            (Name = 'datetime') and 
            (try_convert(datetime2, Value, 126) is not null) 
          then
            'convert(datetime2, N''' + Value + ''', 126)'
          when 
            (Name = 'date') and
            (try_convert(date, Value, 126) is not null)
          then
            'convert(date, N''' + Value + ''', 126)'
          when 
            (Name = 'decimal') and 
            (try_convert(money, Value) is not null)
          then
            Value
          when 
            (Name = 'time') and
            (try_convert(time, Value, 114) is not null) 
          then
            'convert(time, N''' + Value + ''', 114)'
          --when Name = 'fulltext' then
          --  'N''' + 
          --  --replace(System.PrepareSearchText(Value), '''', '''''') +
          --  ''''
          else '# ' + Name + ' #'
        end
      from
        @template.nodes('//sql/node()[not(self::sql)]') N(Node)
        cross apply
        (
          select 
            Node.value('local-name(.)', 'nvarchar(128)') Name,
            Node.value('@xsi:nil', 'bit') Nil,
            Node.value('.', 'nvarchar(max)') Value
        ) V
      for xml path(''), type
    ).value('.', 'nvarchar(max)'),
 
    ''
  );
end; 

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Data].[Entity](
	[EntityID] [int] NOT NULL,
 CONSTRAINT [PK_Entity] PRIMARY KEY CLUSTERED 
(
	[EntityID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Data].[Predicate](
	[PredicateID] [hierarchyid] NOT NULL,
	[EntityID] [int] NOT NULL,
 CONSTRAINT [PK_Predicate] PRIMARY KEY CLUSTERED 
(
	[PredicateID] ASC,
	[EntityID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Data].[PredicateTree](
	[ID] [int] NOT NULL,
	[ParentID] [int] NOT NULL,
	[Answer] [decimal](2, 1) NOT NULL,
	[PredicateID] [hierarchyid] NULL,
	[Populated] [bit] NOT NULL,
 CONSTRAINT [PK_PredicateTree] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Data].[PredicateType](
	[PredicateID] [hierarchyid] NOT NULL,
	[Name] [nvarchar](128) NOT NULL,
	[Expression] [nvarchar](max) NULL,
	[Computed] [bit] NOT NULL CONSTRAINT [DF_PredicateType_Computed]  DEFAULT ((0)),
	[ScopePredicateID] [hierarchyid] NULL,
	[Hidden] [bit] NOT NULL CONSTRAINT [DF_PredicateType_Scope]  DEFAULT ((0)),
	[Imprecise] [bit] NOT NULL CONSTRAINT [DF_PredicateType_Imprecise]  DEFAULT ((0)),
 CONSTRAINT [PK_PredicateType] PRIMARY KEY CLUSTERED 
(
	[PredicateID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Data].[Property](
	[EntityID] [int] NOT NULL,
	[PropertyID] [int] NOT NULL,
	[Value] [nvarchar](4000) NULL
) ON [PRIMARY]

GO
CREATE CLUSTERED INDEX [IX_Property_Property] ON [Data].[Property]
(
	[PropertyID] ASC,
	[EntityID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Data].[PropertyType](
	[PropertyID] [int] NOT NULL,
	[Name] [nvarchar](128) NOT NULL,
	[Type] [nvarchar](256) NOT NULL,
 CONSTRAINT [PK_PropertyType] PRIMARY KEY CLUSTERED 
(
	[PropertyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [Data].[GetEntityProperties](@name nvarchar(128))
returns table
as
return
  select
    P.*
  from 
    Data.PropertyType T
    inner join
    Data.Property P
    on
      (T.Name = @name) and
      (T.PropertyID = P.PropertyID);

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [Data].[Entities]
with schemabinding 
as
select
  count_big(*) EntityCount
from
  Data.Entity;

GO
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NUMERIC_ROUNDABORT OFF

GO
CREATE UNIQUE CLUSTERED INDEX [PK_Entities] ON [Data].[Entities]
(
	[EntityCount] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [Data].[PredicateEntities]
with schemabinding
as
select
  PredicateID, count_big(*) EntityCount
from
  Data.Predicate
group by
  PredicateID
GO
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NUMERIC_ROUNDABORT OFF

GO
CREATE UNIQUE CLUSTERED INDEX [PK_PredicateEntities] ON [Data].[PredicateEntities]
(
	[PredicateID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [Data].[PropertyEntities]
with schemabinding 
as
select
  PropertyID, count_big(*) EntityCount
from
  Data.Property
group by
  PropertyID;










GO
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NUMERIC_ROUNDABORT OFF

GO
CREATE UNIQUE CLUSTERED INDEX [PK_PropertyEntities] ON [Data].[PropertyEntities]
(
	[PropertyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Predicate_Entity] ON [Data].[Predicate]
(
	[EntityID] ASC,
	[PredicateID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_PredicateTree] ON [Data].[PredicateTree]
(
	[ParentID] ASC,
	[Answer] ASC,
	[PredicateID] ASC
)
INCLUDE ( 	[Populated]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_PredicateType] ON [Data].[PredicateType]
(
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Property_Entity] ON [Data].[Property]
(
	[EntityID] ASC,
	[PropertyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
CREATE NONCLUSTERED INDEX [IX_PropertyType] ON [Data].[PropertyType]
(
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NUMERIC_ROUNDABORT OFF

GO
CREATE NONCLUSTERED INDEX [IX_PredicateEntities_EntityCount] ON [Data].[PredicateEntities]
(
	[EntityCount] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NUMERIC_ROUNDABORT OFF

GO
CREATE NONCLUSTERED INDEX [IX_PropertyEntities_EntityCount] ON [Data].[PropertyEntities]
(
	[EntityCount] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [Data].[PredicateTree] ADD  CONSTRAINT [DF_PredicateTree_ID]  DEFAULT (NEXT VALUE FOR [Data].[PredicateTreeID]) FOR [ID]
GO
ALTER TABLE [Data].[PredicateTree] ADD  CONSTRAINT [DF_PredicateTree_Populated]  DEFAULT ((0)) FOR [Populated]
GO
ALTER TABLE [Data].[Predicate]  WITH CHECK ADD  CONSTRAINT [FK_Predicate_Entity] FOREIGN KEY([EntityID])
REFERENCES [Data].[Entity] ([EntityID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [Data].[Predicate] CHECK CONSTRAINT [FK_Predicate_Entity]
GO
ALTER TABLE [Data].[Property]  WITH NOCHECK ADD  CONSTRAINT [FK_Property_Entity] FOREIGN KEY([EntityID])
REFERENCES [Data].[Entity] ([EntityID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [Data].[Property] CHECK CONSTRAINT [FK_Property_Entity]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Defines and populates a predicate
CREATE procedure [Data].[DefinePredicate]
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
  @populate bit = 1,

  -- Debug indicator.
  @debug bit = 0
)
as
begin
  if (@debug = 0)
  begin
	  set nocount on;
  end;
  
  declare @parentID hierarchyid;
  declare @scopeID hierarchyid;

  if (@parent is not null)
  begin
    set @parentID = (select PredicateID from Data.PredicateType where Name = @parent);

    if (@parentID is null)
    begin
      throw 51000, 'Invalid parent predicate.', 1;
    end;
  end
  else
  begin
    set @parentID = '/';
  end;

  if (@scope is not null)
  begin
    set @scopeID = (select PredicateID from Data.PredicateType where Name = @scope);

    if (@scopeID is null)
    begin
      throw 51000, 'Invalid scope predicate.', 1;
    end;
  end;

  declare @childID hierarchyid =
    (
      select
        max(PredicateID.GetAncestor(PredicateID.GetLevel() - @parentID.GetLevel() - 1))
      from
        Data.PredicateType
      where
        (PredicateID.IsDescendantOf(@parentID) = 1) and
        (PredicateID != @parentID)
    );

  declare @predicateID hierarchyid = @parentID.GetDescendant(@childID, null);

  insert into Data.PredicateType(PredicateID, Name, Expression, Computed, Hidden, Imprecise, ScopePredicateID)
  values(@predicateID, @name, @expression, @computed, isnull(@hidden, 0), isnull(@imprecise, 0), @scopeID);

  if ((@populate = 1) and (@computed = 0))
  begin
    execute Data.InvalidatePredicate @predicateID = @predicateID, @debug = @debug;
  end;
end;

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Deletes a predicate. Either @name or @predicateID is required.
create procedure [Data].[DeletePredicate]
(
  -- A predicate name to define.
  @name nvarchar(128) = null,

  -- A predicate id.
  @predicateID hierarchyid = null
)
as
begin
	set nocount on;
  
  if (@predicateID is null)
  begin
    set @predicateID = 
      (select PredicateID from Data.PredicateType where Name = @name);
  end;

  delete from Data.Predicate where PredicateID = @predicateID;
  delete from Data.PredicateType where PredicateID = @predicateID;
end;

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Gets entities for predicates
CREATE procedure [Data].[GetEntities]
(
  -- Request parameters.
  @params xml,
  -- Number of rows to return
  @take int = null,
  -- Optional property value to return.
  @property nvarchar(128) = null,
  -- Debug options
  @debug bit = null
)
as
begin
	set nocount on;

  -- This is to allow EF to guess type of result.
  if (1 = 0)
  begin
    select
      EntityID,
      cast(null as nvarchar(4000)) Value
    from
      Data.Entity
  end;

  declare @sql nvarchar(max) = 
    Dynamic.GetSQL_GetEntities(@params, @take, @property);

  if (@debug = 1)
  begin
    print @sql;
  end;

  execute sp_executesql @sql,
    @params = N'@take int, @property nvarchar(128)',
    @take = @take,
    @property = @property;
end;

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Gets next predicates
CREATE procedure [Data].[GetNextPredicates]
(
  -- Request parameters.
  @params xml,

  -- Result as a predicate
  @result xml output,

  -- Debug options
  @debug bit = null
)
as
begin
	set nocount on;

  set @result = null;

  -- Number of rows to return
  declare @take int = 5;

  declare @question table
  (
    PredicateID hierarchyid not null primary key,
    Answer decimal(2, 1) not null
  );

  declare @questionID table
  (
    PredicateID hierarchyid not null primary key,
    ID int not null,
    New bit not null
  );

  with Data as
  (
    select cast(isnull(@params, '<request/>') as xml(document Data.XmlTypes)) Data
  ),
  Predicate as
  (
    select
      P.PredicateID,
      case when P.Imprecise = 1
        then cast(Q.Answer * 0.8 + 0.1 as decimal(2, 1))
        else Q.Answer
      end Answer
    from
      Data
      cross apply
      Data.nodes('/request/*') N(Node)
      inner loop join
      Data.PredicateType P
      on
        P.Name = Node.value('self::question/@name', 'nvarchar(128)')
      cross apply
      (select Node.value('self::question/@answer', 'decimal(2, 1)') Answer) Q
  )
  insert into @question(PredicateID, Answer)
  select PredicateID, Answer from Predicate;

  declare @questionCount int = @@rowcount;
  declare @retry int = @questionCount;

  while(@retry > 0)
  begin
    set @retry -= 1;

    with Q as
    (
      select
        cast(row_number() over(order by PredicateID) as int) Row,
        *
      from
        @question
    ),
    T as
    (
      select
        0 Row,
        0 ID,
        0 ParentID,
        cast(1 as decimal(2, 1)) Answer,
        cast('/' as hierarchyid) PredicateID
      union all
      select
        Q.Row,
        P.ID,
        T.ID,
        Q.Answer,
        Q.PredicateID
      from
        Q
        inner join
        T
        on
          Q.Row = T.Row + 1
        inner join
        Data.PredicateTree P
        on
          (P.ParentID = T.ID) and
          (P.Answer = T.Answer) and
          (P.PredicateID = Q.PredicateID)
    )
    insert into @questionID(PredicateID, ID, New)
    select PredicateID, ID, 0 from T
    option(maxrecursion 0);

    if (@@rowcount >= @questionCount)
    begin
      break;
    end;

    insert into @questionID(PredicateID, ID, New)
    select
      PredicateID,
      next value for Data.PredicateTreeID over(order by PredicateID),
      1
    from
      @question
    where
      PredicateID not in (select PredicateID from @questionID);

    if (@@rowcount = 0)
    begin
      break;
    end;

    begin try
      with Q as
      (
        select
          I.*, Q.Answer
        from
          @question Q
          inner join
          @questionID I
          on
            I.PredicateID = Q.PredicateID
      ),
      T as
      (
        select
          ID, 
          lag(ID, 1, 0) over(order by PredicateID) ParentID, 
          lag(Answer, 1, 1) over(order by PredicateID) Answer, 
          PredicateID,
          New
        from
          Q
      )
      insert into Data.PredicateTree(ID, ParentID, Answer, PredicateID, Populated)
      select
        ID, ParentID, Answer, PredicateID, 0
      from
        T
      where
        New = 1;

      break;
    end try
    begin catch
      if (@debug = 1)
      begin
        print concat('Error: ', error_number(), '. ', error_message());
      end;

      -- Cannot insert duplicate key row.
      if (error_number() != 2601)
      begin
        throw;
      end;

      delete from @questionID;
    end catch;
  end;

  declare @id int = null;
  declare @answer decimal(2, 1) = null;

  if (@questionCount > 0)
  begin
    with Q as
    (
      select
        I.*, Q.Answer
      from
        @question Q
        inner join
        @questionID I
        on
          I.PredicateID = Q.PredicateID
    )
    select top 1
      @id = ID,
      @answer = Answer
    from
      Q
    order by
      PredicateID desc;
  end;

  if (@id is null)
  begin
    set @id = 0;
    set @answer = 1;
  end;

  if (@debug = 1)
  begin
    print concat('Tree ID: ', @id, ', answer: ', @answer);
  end;

  set @retry = 2;

  while(@retry != 0)
  begin
    set @retry -= 1;

    declare @matches bit = null;

    with question as
    (
      select
        T.Name name
      from
        Data.PredicateTree P
        left join
        Data.PredicateType T
        on
          T.PredicateID = P.PredicateID
      where
        (P.ParentID = @id) and
        (P.Answer = @answer) and
        (P.Populated = 1)
    )
    select 
      @result = (select * from question where name is not null for xml auto),
      @matches = (select top 1 1 from question)

    if (@matches = 1)
    begin
      break;
    end;

    create table #predicate
    (
      Weight decimal(5, 4) not null,
      PredicateID hierarchyid not null,
      Deviation decimal(2, 1),
      primary key(Weight, PredicateID)
    );

    declare @time1 datetime2(7) = current_timestamp;
    declare @sql nvarchar(max) = 
      Dynamic.GetSQL_GetNextPredicate(@params) +
      N'insert into #predicate(Weight, PredicateID, Deviation)
select top(@take) Weight, PredicateID, Deviation from R order by Weight desc, Deviation';

    declare @time2 datetime2(7) = current_timestamp;

    if (@debug = 1)
    begin
      print concat('SQL build time: ', datediff(millisecond, @time1, @time2), 'ms.');
      print @sql;
    end;

    execute sp_executesql @sql,
      @params = N'@take int',
      @take = @take;

    declare @matchCount int = @@rowcount;

    declare @time3 datetime2(7) = current_timestamp;

    if (@debug = 1)
    begin
      print concat('Execution time: ', datediff(millisecond, @time2, @time3), 'ms.');
    end;

    set @retry = 2;

    while(@retry > 0)
    begin
      set @retry -= 1;

      begin try
        with M as
        (
          select 
            dense_rank() over(order by Weight, Deviation) Rank,
            PredicateID
          from 
            #predicate
        ),       
        P as
        (
          select 
            PredicateID 
          from 
            M
          where 
            (Rank = 1) and
            (@matchCount >= 2)
          union all
          select null where @matchCount < 2
        ),
        T as
        (
          select
            *
          from
            Data.PredicateTree with(index(IX_PredicateTree))
          where
            (ParentID = @id) and
            (Answer = @answer)
        )
        merge T
        using P
        on
          (T.PredicateID = P.PredicateID) or
          ((T.PredicateID is null) and (P.PredicateID is null))
        when matched then
          update set Populated = 1
        when not matched by target then
          insert(ParentID, Answer, PredicateID, Populated)
          values(@id, @answer, P.PredicateID, 1)
        when not matched by source then
          delete;

        break;
      end try
      begin catch
        if (@debug = 1)
        begin
          print concat('Error: ', error_number(), '. ', error_message());
        end;

        -- Cannot insert duplicate key row.
        if (error_number() != 2601)
        begin
          throw;
        end;
      end catch;
    end;

    set @retry = 1;
  end;
end;

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Invalidates a predicate. Either @predicateID or @name is required.
CREATE procedure [Data].[InvalidatePredicate]
(
  -- A predicate id.
  @predicateID hierarchyid = null,

  -- A predicate name.
  @name nvarchar(128) = null,

  -- Debug indicator.
  @debug bit = 0
)
as
begin
  if (@debug = 0)
  begin
	  set nocount on;
  end;

  if (@predicateID is null)
  begin
    set @predicateID = 
      (select PredicateID from Data.PredicateType where Name = @name);
  end;

  declare @sql nvarchar(max) =
    N'insert into Data.Predicate(PredicateID, EntityID)
select distinct @predicateID, EntityID from ' +
    (
      select 
        Expression 
      from 
        Data.PredicateType 
      where 
        (Computed = 0) and
        (PredicateID = @predicateID)
    );

  if (@debug = 1)
  begin
    raiserror(@sql, 0, 1) with nowait;
  end;

  declare @time1 datetime2(7) = current_timestamp;

  delete from Data.Predicate where PredicateID = @predicateID;

  execute sp_executesql @sql,
    @params = N'@predicateID hierarchyid',
    @predicateID = @predicateID;

  declare @time2 datetime2(7) = current_timestamp;

  if (@debug = 1)
  begin
    print concat('Execution time: ', datediff(millisecond, @time1, @time2), 'ms.');
  end;

  execute Data.InvalidatePredicateTree;
end;

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Invalidates all predicates
create procedure [Data].[InvalidatePredicates]
(
  @debug bit = 0
)
as
begin
	set nocount on;

  declare @predicateID hierarchyid;

  declare Predicates cursor for
  select 
    PredicateID
  from
    Data.PredicateType
  where
    (Expression is not null) and
    (Computed = 0);

  open Predicates;

  fetch next from Predicates into @predicateID;

  while @@fetch_status = 0
  begin
    exec Data.InvalidatePredicate @predicateID = @predicateID, @debug = @debug;

    fetch next from Predicates into @predicateID;
  end;

  close Predicates;
  deallocate Predicates;
end;

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Invalidates a predicate. Either @predicateID or @name is required.
create procedure [Data].[InvalidatePredicateTree]
as
begin
  begin transaction;
  truncate table Data.PredicateTree;
  alter sequence Data.PredicateTreeID restart with 1;
  commit;
end;

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
declare @result xml;

  execute Data.PlaySearch @entityID = 5, @result = @result output;

  select @result;

*/

-- Plays the search.
CREATE procedure [Data].[PlaySearch]
(
  -- An entityID to search.
  @entityID int,

  -- Maximum number of questions
  @maxQuestions int = 30,

  -- Output response.
  @result xml output,

  -- Use randomness while selecting new question.
  @randomness bit = 0,

  -- Debug indicator.
  @debug bit = 0
)
as
begin
	set nocount on;

  declare @entityPredicate table
  (
    PredicateID hierarchyid not null primary key
  );

  declare @currentPredicate table
  (
    ID int identity(1, 1),
    PredicateID hierarchyid not null primary key,
    Answer decimal(2, 1) not null
  );

  insert into @entityPredicate(PredicateID)
  select PredicateID from Data.Predicate where EntityID = @entityID;

  declare @i int = 0;

  while(@i <= @maxQuestions)
  begin
    set @i += 1;

    declare @params xml;

    with question as
    (
      select
        C.ID,
        T.Name, 
        C.Answer
      from
        @currentPredicate C
        inner join
        Data.PredicateType T
        on
          C.PredicateID = T.PredicateID
    )
    select 
      @params = 
        (
          select
            Name name,
            Answer answer
          from
            question
          order by
            ID
          for xml auto, root('request')
        );

    declare @nextPredicate xml;

    execute Data.GetNextPredicates 
      @params = @params, 
      @result = @nextPredicate output, 
      @debug = @debug;

    if (@nextPredicate is null)
    begin
      break;
    end;

    -- Select a predicate.
    declare @predicateID hierarchyid = 
      (
        select top 1 
          T.PredicateID
        from
          @nextPredicate.nodes('//question') N(Node)
          inner loop join
          Data.PredicateType T
          on
            T.Name = Node.value('@name', 'nvarchar(128)')
        order by
          case when @randomness = 1 then
            iif(T.PredicateID in (select PredicateID from @entityPredicate), 0, 1)
          end,
          case when @randomness = 1 then  newid() end,
          T.PredicateID
      );

    declare @answer decimal(2, 1) =
      iif(@predicateID in (select PredicateID from @entityPredicate), 1, 0);

    insert into @currentPredicate(PredicateID, Answer)
    values(@predicateID, @answer);
  end;

  with question as
  (
    select
      C.ID,
      T.Name, 
      C.Answer
    from
      @currentPredicate C
      inner join
      Data.PredicateType T
      on
        C.PredicateID = T.PredicateID
  )
  select 
    @result = 
      (
        select
          Name name,
          Answer answer
        from
          question
        order by
          ID
        for xml auto, root('request')
      );
end;

GO

