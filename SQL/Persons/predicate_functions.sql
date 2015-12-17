CREATE function[Data].[Predicate_DealsWithRaceHorses]()
returns table
as
return
  select
    EntityID
  from 
    Data.GetEntityProperties('22-rdf-syntax-ns#type_label')
  where 
    Value like '%Racehorse%'

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_HasAwards]()
returns table
as
return
  select
    EntityID
  from 
    Data.GetEntityProperties('award_label')


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_HasBlackHairs]()
returns table
as
return
  select
    EntityID
  from
    Data.GetEntityProperties('hairColor')
	where
    Value in (
'Black',
'Dark Brown/Black',
'Jet Black',
'Black (natural)'
)


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_HasBrownHairs]()
returns table
as
return
  select
    EntityID
  from
    Data.GetEntityProperties('hairColor')
	where
    Value in (
'Brown',
'Brunette',
'Dark Brown',
'Light brown',
'Ash Brown',
'Brown (dyed)'
)


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_HasChef]()
returns table
as
return
  select
    EntityID
  from 
    Data.GetEntityProperties('HasChef')
  where
    (Value in (N'כן', '1', 'yes', 'true'))


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_HasLightHairs]()
returns table
as
return
  select
    EntityID
  from
    Data.GetEntityProperties('hairColor')
	where
    Value in (
'Blonde',
'blond',
'Dark Blonde',
'dark blond',
'Honey Brown',
'Platinum blond'
)


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_HasReddishHairs]()
returns table
as
return
  select
    EntityID
  from
    Data.GetEntityProperties('hairColor')
	where
    Value in (
'Chestnut Brown',
'Red',
'Auburn',
'Burgundy',
'Reddish Brown'
)


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_IsActor]()
returns table
as
return
  select
    EntityID
  from 
    Data.GetEntityProperties('22-rdf-syntax-ns#type_label')
  where
    (Value in ('actor'))

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_IsAmericanFootballPlayer]()
returns table
as
return
  select
    EntityID
  from 
    Data.GetEntityProperties('22-rdf-syntax-ns#type_label')
  where
    (Value = 'american football player')


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_IsArchitect]()
returns table
as
return
  select
    EntityID
  from 
    Data.GetEntityProperties('22-rdf-syntax-ns#type_label')
  where
    (Value = 'architect')

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_IsArtist]()
returns table
as
return
  select
    EntityID
  from 
    Data.GetEntityProperties('22-rdf-syntax-ns#type_label')
  where
    (Value = 'artist')

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function[Data].[Predicate_IsAstronaut]()
returns table
as
return
  select
    EntityID
  from 
    Data.GetEntityProperties('22-rdf-syntax-ns#type')
  where
    (Value = 'http://dbpedia.org/ontology/Astronaut')

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_IsBaroqueComposer]()
returns table
as
return
  select
    EntityID
  from 
    Data.GetEntityProperties('22-rdf-syntax-ns#type_label')
  where
    (Value = 'BaroqueComposers')

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_IsBaseballPlayer]()
returns table
as
return
  select
    EntityID
  from
    Data.GetEntityProperties('22-rdf-syntax-ns#type')
  where
    Value in (
	 'http://dbpedia.org/ontology/BaseballPlayer',
	 'http://umbel.org/umbel/rc/BaseballPlayer'
	)


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_IsBasketballPlayer]()
returns table
as
return
  select
    EntityID
  from 
    Data.GetEntityProperties('22-rdf-syntax-ns#type_label')
  where
    (Value like 'BasketballPlayer%')


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function[Data].[Predicate_IsBeautyQueen]()
returns table
as
return
  select
    EntityID
  from 
    Data.GetEntityProperties('22-rdf-syntax-ns#type')
  where
    (Value = 'http://dbpedia.org/ontology/BeautyQueen')

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_IsBoxer]()
returns table
as
return
  select
    EntityID
  from 
    Data.GetEntityProperties('22-rdf-syntax-ns#type_label')
  where
    (Value like 'Boxer%')


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_IsBusinessPerson]()
returns table
as
return
  select
    EntityID
  from 
    Data.GetEntityProperties('22-rdf-syntax-ns#type')
  where
    (Value = 'http://dbpedia.org/ontology/BusinessPerson')

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_IsChessPlayer]()
returns table
as
return
  select
    EntityID
  from 
    Data.GetEntityProperties('22-rdf-syntax-ns#type_label')
  where
    (Value like '%ChessPlayer%')

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_IsCoach]()
returns table
as
return
  select
    EntityID
  from 
    Data.GetEntityProperties('22-rdf-syntax-ns#type_label')
  where
    (Value like '%Coach%')


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_IsComedian]()
returns table
as
return
  select
    EntityID
  from 
    Data.GetEntityProperties('22-rdf-syntax-ns#type')
  where
    (Value in
	 ('http://dbpedia.org/ontology/Comedian', 'http://umbel.org/umbel/rc/Comedian'))

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_IsComposer]()
returns table
as
return
  select
    EntityID
  from 
    Data.GetEntityProperties('22-rdf-syntax-ns#type_label')
  where
    (Value like '%Composer%')

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_IsCriminal]()
returns table
as
return
  select
    EntityID
  from 
    Data.GetEntityProperties('22-rdf-syntax-ns#type_label')
  where
    (Value like 'criminal%')

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_IsFemale]()
returns table
as
return
  select
    EntityID
  from 
    Data.GetEntityProperties('gender_label')
  where
	  (Value = 'Female')


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_IsFictionalCharacter]()
returns table
as
return
  select
    EntityID
  from 
    Data.GetEntityProperties('22-rdf-syntax-ns#type_label')
  where
    (Value = 'fictional character')

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_IsFigureSkater]()
returns table
as
return
  select
    EntityID
  from 
    Data.GetEntityProperties('22-rdf-syntax-ns#type_label')
  where
    (Value like '%FigureSkater%')


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_IsFootballPlayer]()
returns table
as
return
  select
    EntityID
  from
    Data.GetEntityProperties('22-rdf-syntax-ns#type_label')
	where
    Value like 'FootballPlayer%'


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_IsFromGreekMythology]()
returns table
as
return
  select
    EntityID
  from
    Data.GetEntityProperties('mythology_label')
  where
    Value in (
'Greek mythology',
'"Greek mythology"'
)

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_IsGymnast]()
returns table
as
return
  select
    EntityID
  from
    Data.GetEntityProperties('22-rdf-syntax-ns#type_label')
  where
    Value in ('Gymnast', 'gymnast')

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function[Data].[Predicate_IsHistorian]()
returns table
as
return
  select
    EntityID
  from 
    Data.GetEntityProperties('22-rdf-syntax-ns#type')
  where
    (Value = 'http://dbpedia.org/ontology/Historian')

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_IsIceHockeyPlayer]()
returns table
as
return
  select
    EntityID
  from 
    Data.GetEntityProperties('22-rdf-syntax-ns#type_label')
  where
    (Value = 'ice hockey player')


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function[Data].[Predicate_IsJournalist]()
returns table
as
return
  select
    EntityID
  from 
    Data.GetEntityProperties('22-rdf-syntax-ns#type_label')
  where
    (Value like 'Journalist%')

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function[Data].[Predicate_IsJudge]()
returns table
as
return
  select
    EntityID
  from 
    Data.GetEntityProperties('22-rdf-syntax-ns#type_label')
  where
    (Value = 'judge')

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_IsKnownEconomist]()
returns table
as
return
  select
    EntityID
  from
    Data.GetEntityProperties('knownFor_label')
	where
    Value in ('Economist', 'Economics', 'Finance')


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_IsKnownForActivism]()
returns table
as
return
  select
    EntityID
  from
    Data.GetEntityProperties('knownFor_label')
	where
    Value = 'Activism'


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_IsKnownForAstronomyOrAstrophysics]()
returns table
as
return
  select
    EntityID
  from
    Data.GetEntityProperties('knownFor_label')
	where
    Value in (
'Astronomy',
'Astrophysics',
'Dark matter',
'String theory',
'Superstring theory',
'Chaos theory'
)


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_IsKnownForBotanyOrBiology]()
returns table
as
return
  select
    EntityID
  from
    Data.GetEntityProperties('knownFor_label')
	where
    Value in (
'Botany',
'Plant pathology',
'Flora',
'Zoology',
'Ornithology',
'Taxonomy (biology)',
'Entomology',
'Cell biology',
'Neuroscience'
)


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_IsKnownForCancerResearch]()
returns table
as
return
  select
    EntityID
  from
    Data.GetEntityProperties('knownFor_label')
	where
    Value in ('Cancer research', 'Cancer')


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_IsKnownForChemistry]()
returns table
as
return
  select
    EntityID
  from
    Data.GetEntityProperties('knownFor_label')
	where
    Value in (
'Quantum chemistry',
'Organometallic chemistry',
'Stereochemistry',
'Periodic table'
)


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_IsKnownForComputerScience]()
returns table
as
return
  select
    EntityID
  from
    Data.GetEntityProperties('knownFor_label')
	where
    Value in (
'Computer science',
'Ubiquitous computing',
'Humanâ€“computer interaction',
'Health informatics',
'Econometrics',
'Cryptanalysis',
'Information theory',
'Artificial intelligence',
'Computer security',
'Computational geometry',
'Robotics',
'Supercomputer'
)


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_IsKnownForFeminism]()
returns table
as
return
  select
    EntityID
  from
    Data.GetEntityProperties('knownFor_label')
	where
    Value in ('Feminism', 'Women''s rights')


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_IsKnownForGenetics]()
returns table
as
return
  select
    EntityID
  from
    Data.GetEntityProperties('knownFor_label')
	where
    Value in (
'Embryogenesis',
'Genetics',
'Transduction (genetics)',
'DNA',
'Ancient DNA',
'DNA repair',
'Population genetics'
)


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_IsKnownForHumanRights]()
returns table
as
return
  select
    EntityID
  from
    Data.GetEntityProperties('knownFor_label')
	where
    Value in ('Human rights', 'Human rights defender')


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_IsKnownForInternet]()
returns table
as
return
  select
    EntityID
  from
    Data.GetEntityProperties('knownFor_label')
	where
    Value in (
'Video blog',
'Blog',
'YouTube'
)


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_IsKnownForMathematic]()
returns table
as
return
  select
    EntityID
  from
    Data.GetEntityProperties('knownFor_label')
	where
    Value in (
'Partial differential equation',
'Combinatorics',
'Functional analysis',
'Group theory',
'Differential geometry',
'Dynamical system',
'Dynamical systems theory',
'Topology',
'Finite element method',
'Mathematical analysis',
'Algebraic geometry',
'Analytic number theory',
'Systems theory',
'Graph theory',
'Game theory',
'Numerical analysis',
'Set theory',
'Statistics',
'Operations research',
'Nonlinear system',
'Geometric measure theory',
'Applied mathematics'
)


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_IsKnownForMedicine]()
returns table
as
return
  select
    EntityID
  from
    Data.GetEntityProperties('knownFor_label')
	where
    Value in (
'Medicine',
'Immunology',
'Dermatology',
'Diabetes mellitus',
'Public health',
'Surgical pathology',
'Penicillin',
'Tuberculosis'
)


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_IsKnownForPhilanthropy]()
returns table
as
return
  select
    EntityID
  from
    Data.GetEntityProperties('knownFor_label')
	where
    Value = 'Philanthropy'


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_IsKnownForPhotography]()
returns table
as
return
  select
    EntityID
  from
    Data.GetEntityProperties('knownFor_label')
	where
    Value in ('Photography', 'photography')


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_IsKnownForPhysics]()
returns table
as
return
  select
    EntityID
  from
    Data.GetEntityProperties('knownFor_label')
	where
    Value in (
'Nuclear magnetic resonance',
'Nuclear physics',
'High-temperature superconductivity',
'Quantum field theory',
'Mass spectrometry',
'Particle physics',
'Relative atomic mass',
'Nanotechnology',
'General relativity',
'X-ray crystallography',
'Phase transition',
'Fluid dynamics',
'Thermodynamics',
'Carbon nanotube',
'Plasma (physics)',
'Quantum mechanics',
'Electron',
'Gravitation',
'Cosmic ray',
'Ultracold atom',
'Supersymmetry',
'Theoretical physics',
'Thermoelectric effect',
'X-ray',
'Mathematical physics',
'Superconductivity',
'Statistical mechanics'
)


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_IsKnownInIndia]()
returns table
as
return
  select
    EntityID
  from
    Data.GetEntityProperties('knownFor_label')
	where
    Value in ('Indian independence movement', 'India')


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_IsLivingPerson]()
returns table
as
return
  select
    EntityID
  from 
    Data.GetEntityProperties('22-rdf-syntax-ns#type_label')
  where
    (Value = 'LivingPeople')

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_IsMale]()
returns table
as
return
  select
    EntityID
  from 
    Data.GetEntityProperties('gender_label')
  where 
    (Value = 'Male')


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_IsMilitary]()
returns table
as
return
  select
    EntityID
  from
    Data.GetEntityProperties('militaryCommand')
  union all
  select
    EntityID
  from
    Data.GetEntityProperties('militaryBranch_label')
  union all
  select
    EntityID
  from 
    Data.GetEntityProperties('militaryUnit_label')
  union all
  select
    EntityID
  from 
    Data.GetEntityProperties('militaryRank_label')
  union all
  select
    EntityID
  from
    Data.GetEntityProperties('22-rdf-syntax-ns#type_label')
  where
    (Value = 'military person')

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_IsMinister]()
returns table
as
return
  select
    EntityID
  from 
    Data.GetEntityProperties('22-rdf-syntax-ns#type_label')
  where
    (Value like 'Minister%')

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_IsModel]()
returns table
as
return
  select
    EntityID
  from 
    Data.GetEntityProperties('22-rdf-syntax-ns#type_label')
  where
    (Value = 'model')

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_IsMonarch]()
returns table
as
return
  select
    EntityID
  from 
    Data.GetEntityProperties('22-rdf-syntax-ns#type_label')
  where
    (Value in ('Monarch', 'monarch'))

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_IsMonarchist]()
returns table
as
return
  select
    EntityID
  from 
    Data.GetEntityProperties('22-rdf-syntax-ns#type_label')
  where
    (Value like 'Monarchist%')

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_IsMotorsportRacer]()
returns table
as
return
  select
    EntityID
  from 
    Data.GetEntityProperties('22-rdf-syntax-ns#type_label')
  where
    (Value = 'motorsport racer')


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_IsMusician]()
returns table
as
return
  select
    EntityID
  from
    Data.GetEntityProperties('22-rdf-syntax-ns#type_label')
  where
	  Value like '%Musician%'


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_IsNoble]()
returns table
as
return
  select
    EntityID
  from 
    Data.GetEntityProperties('22-rdf-syntax-ns#type')
  where
    (Value = 'http://dbpedia.org/ontology/Noble')

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_IsOfficer]()
returns table
as
return
  select
    EntityID
  from 
    Data.GetEntityProperties('22-rdf-syntax-ns#type_label')
	where
	Value like '%Officer%'


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_IsOrganist]()
returns table
as
return
  select
    EntityID
  from
    Data.GetEntityProperties('22-rdf-syntax-ns#type_label')
  where
	  Value like '%Organist%'


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_IsPainter]()
returns table
as
return
  select
    EntityID
  from 
    Data.GetEntityProperties('22-rdf-syntax-ns#type_label')
  where
    (Value in ('Painter', 'painter'))

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_IsPhilosopher]()
returns table
as
return
  select
    EntityID
  from 
    Data.GetEntityProperties('22-rdf-syntax-ns#type_label')
  where
    (Value = 'philosopher')

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function[Data].[Predicate_IsPoet]()
returns table
as
return
  select
    EntityID
  from 
    Data.GetEntityProperties('22-rdf-syntax-ns#type')
  where
    (Value = 'http://dbpedia.org/ontology/Poet')

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_IsPolitician]()
returns table
as
return
  select
    EntityID
  from
    Data.GetEntityProperties('22-rdf-syntax-ns#type_label')
	where
    Value like '%Politician%'


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function[Data].[Predicate_IsPope]()
returns table
as
return
  select
    EntityID
  from 
    Data.GetEntityProperties('22-rdf-syntax-ns#type')
  where
    (Value = 'http://dbpedia.org/ontology/Pope')

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_IsPracticingMartialArts]()
returns table
as
return
  select
    EntityID
  from
    Data.GetEntityProperties('22-rdf-syntax-ns#type_label')
  where
	  Value like '%Practitioners%'


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_IsPresident]()
returns table
as
return
  select
    EntityID
  from 
    Data.GetEntityProperties('22-rdf-syntax-ns#type_label')
  where
    (Value like '%President%')

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_IsPrimeMinister]()
returns table
as
return
  select
    EntityID
  from 
    Data.GetEntityProperties('22-rdf-syntax-ns#type_label')
  where
    (Value like 'PrimeMinister%')

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_IsRacingDriver]()
returns table
as
return
  select
    EntityID
  from 
    Data.GetEntityProperties('22-rdf-syntax-ns#type_label')
  where
    (Value = 'racing driver')


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_IsReligious]()
returns table
as
return
  select
    EntityID
  from
    Data.GetEntityProperties('religion_label')
  group by 
    EntityID


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_IsRugbyPlayer]()
returns table
as
return
  select
    EntityID
  from 
    Data.GetEntityProperties('22-rdf-syntax-ns#type_label')
  where
    (Value = 'rugby player')


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_IsSaint]()
returns table
as
return
  select
    EntityID
  from 
    Data.GetEntityProperties('22-rdf-syntax-ns#type')
  where
    (Value = 'http://dbpedia.org/ontology/Saint')

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_IsScientist]()
returns table
as
return
  select
    EntityID
  from 
    Data.GetEntityProperties('22-rdf-syntax-ns#type_label')
  where
    (Value like '%Scientist%')

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_IsSinger]()
returns table
as
return
  select
    EntityID
  from
    Data.GetEntityProperties('22-rdf-syntax-ns#type_label')
  where
    (Value like '%Singer%')

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_IsSoapCharacter]()
returns table
as
return
  select
    EntityID
  from 
    Data.GetEntityProperties('22-rdf-syntax-ns#type_label')
  where
    (Value = 'soap character')

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_IsSportManager]()
returns table
as
return
  select
    EntityID
  from 
    Data.GetEntityProperties('22-rdf-syntax-ns#type_label')
  where
    (Value in ('sports manager', 'soccer manager'))

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_IsSwimmer]()
returns table
as
return
  select
    EntityID
  from 
    Data.GetEntityProperties('22-rdf-syntax-ns#type_label')
  where
    (Value = 'swimmer')


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function[Data].[Predicate_IsTall]()
returns table
as
return
  select
    EntityID
  from
    Data.GetEntityProperties('height')
    cross apply
    (
      select try_cast(Value as money) DecimalValue
    ) V
  where
    (iif(DecimalValue < 3, DecimalValue * 100, DecimalValue) >= 185)

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_IsTelevisionTalkShowHosts]()
returns table
as
return
  select
    EntityID
  from 
    Data.GetEntityProperties('22-rdf-syntax-ns#type_label')
  where
    (Value like '%TelevisionTalkShowHosts%')

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_IsWorkingOnFriday]()
returns table
as
return
  select
    EntityID
  from 
    Data.GetEntityProperties('OpenOnFriday')
  where
    (Value in (N'כן', 'yes', 'true', '1'))



GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_IsWorkingOnSaturday]()
returns table
as
return
  select
    EntityID
  from 
    Data.GetEntityProperties('OpenOnSaturday')
  where
    (Value in (N'כן', 'yes', 'true', '1'))


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_IsWriter]()
returns table
as
return
  select
    EntityID
  from 
    Data.GetEntityProperties('22-rdf-syntax-ns#type_label')
  where
    (Value = 'writer')

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_Location]()
returns table
as
return
  select
    EntityID
  from
    Data.GetEntityProperties('nationality_label')
  union all
  select
    EntityID
  from 
    Data.GetEntityProperties('birthPlace_label')

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_Sex]()
returns table
as
return
  select
    EntityID
  from 
    Data.GetEntityProperties('gender_label')


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_WasBornInAfrica]()
returns table
as
return
  select
    EntityID
  from
    Data.Predicate
  where
    --PredicateID in (Data.GetPredicateID('WasBornInBrazil'), Data.GetPredicateID('WasBornInArgentina'));
    1 = 0

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_WasBornInArgentina]()
returns table
as
return
  select
    EntityID
  from
    Data.GetEntityProperties('birthPlace_label')
	where
    Value = 'Argentina'


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_WasBornInAustraliaOrNewZeland]()
returns table
as
return
  select
    EntityID
  from
    Data.GetEntityProperties('birthPlace_label')
	where
    Value in (
'Australia',
'Victoria (Australia)',
'Western Australia',
'South Australia',
'New Zealand'
	
	)


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_WasBornInBrazil]()
returns table
as
return
  select
    EntityID
  from
    Data.GetEntityProperties('birthPlace_label')
	where
    Value = 'Brazil'


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_WasBornInCanada]()
returns table
as
return
  select
    EntityID
  from
    Data.GetEntityProperties('birthPlace_label')
	where
    Value = 'Canada'


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_WasBornInChina]()
returns table
as
return
  select
    EntityID
  from
    Data.GetEntityProperties('birthPlace_label')
	where
    Value in (
'China',
'Republic of China (1912GÇô49)',
'Mainland China'
	)


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_WasBornInFarEast]()
returns table
as
return
  select
    EntityID
  from
    Data.Predicate
  where
    PredicateID in 
      (
        Data.GetPredicateID('WasBornInJapan'), 
        Data.GetPredicateID('WasBornInKorea'),
        Data.GetPredicateID('WasBornInChina')
      );
  

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_WasBornInFrance]()
returns table
as
return
  select
    EntityID
  from
    Data.GetEntityProperties('birthPlace_label')
	where
    Value = 'France'


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_WasBornInGermany]()
returns table
as
return
  select
    EntityID
  from
    Data.GetEntityProperties('birthPlace_label')
	where
    Value in
	(
	 'Germany',
	 'West Germany',
	 'East Germany'
	)


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_WasBornInIndia]()
returns table
as
return
  select
    EntityID
  from
    Data.GetEntityProperties('birthPlace_label')
	where
    Value in ('India', 'Presidencies and provinces of British India')


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_WasBornInIsrael]()
returns table
as
return
  select
    EntityID
  from
    Data.GetEntityProperties('birthPlace_label')
	where
    Value = 'Israel'


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_WasBornInItaly]()
returns table
as
return
  select
    EntityID
  from
    Data.GetEntityProperties('birthPlace_label')
	where
    Value = 'Italy'


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_WasBornInJapan]()
returns table
as
return
  select
    EntityID
  from
    Data.GetEntityProperties('birthPlace_label')
	where
    Value = 'Japan'


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_WasBornInKorea]()
returns table
as
return
  select
    EntityID
  from
    Data.GetEntityProperties('birthPlace_label')
	where
    Value in (
'South Korea',
'North Korea',
'Korea'
	)


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_WasBornInMidleEast]()
returns table
as
return
  select
    EntityID
  from
    Data.Predicate
  where
    PredicateID in 
      (
        Data.GetPredicateID('WasBornInIsrael'), 
        Data.GetPredicateID('WasBornInTurkey')
      );


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_WasBornInNetherlands]()
returns table
as
return
  select
    EntityID
  from
    Data.GetEntityProperties('birthPlace_label')
	where
    Value = 'Netherlands'


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_WasBornInNorthAmerica]()
returns table
as
return
  select
    EntityID
  from
    Data.Predicate
  where
    PredicateID in (Data.GetPredicateID('WasBornInUSA'), Data.GetPredicateID('WasBornInCanada'));

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_WasBornInPoland]()
returns table
as
return
  select
    EntityID
  from
    Data.GetEntityProperties('birthPlace_label')
	where
    Value = 'Poland'


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_WasBornInRussia]()
returns table
as
return
  select
    EntityID
  from
    Data.GetEntityProperties('birthPlace_label')
	where
    Value in (
'Russia',
'Russian Empire'
	)


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_WasBornInRussiaOrInSovietUnion]()
returns table
as
return
  select
    EntityID
  from
    Data.GetEntityProperties('birthPlace_label')
	where
    Value in (
'Russia',
'Russian Empire',
'Soviet Union',
'Russian Soviet Federative Socialist Republic',
'Ukrainian Soviet Socialist Republic',
'Byelorussian Soviet Socialist Republic',
'Georgian Soviet Socialist Republic',
'Kazakh Soviet Socialist Republic',
'Latvian Soviet Socialist Republic',
'Lithuanian Soviet Socialist Republic',
'Azerbaijan Soviet Socialist Republic',
'Uzbek Soviet Socialist Republic',
'Armenian Soviet Socialist Republic',
'Moldavian Soviet Socialist Republic',
'Kirghiz Soviet Socialist Republic',
'Tajik Soviet Socialist Republic',
'Turkmen Soviet Socialist Republic',
'Abkhaz Autonomous Soviet Socialist Republic',
'Estonian Soviet Socialist Republic',
'Dagestan Autonomous Soviet Socialist Republic',
'ChechenGÇôIngush Autonomous Soviet Socialist Republic',
'Chuvash Autonomous Soviet Socialist Republic',
'Tatar Autonomous Soviet Socialist Republic',
'Nakhchyvan Autonomous Soviet Socialist Republic',
'North Ossetian Autonomous Soviet Socialist Republic',
'Bashkir Autonomous Soviet Socialist Republic',
'Mordovian Autonomous Soviet Socialist Republic',
'Kabardino-Balkar Autonomous Soviet Socialist Republic',
'Mari Autonomous Soviet Socialist Republic',
'Kalmyk Autonomous Soviet Socialist Republic',
'Udmurt Autonomous Soviet Socialist Republic',
'Karelian Autonomous Soviet Socialist Republic',
'Adjar Autonomous Soviet Socialist Republic',
'Komi Autonomous Soviet Socialist Republic',
'Yakut Autonomous Soviet Socialist Republic'
	)


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_WasBornInSouthAmerica]()
returns table
as
return
  select
    EntityID
  from
    Data.Predicate
  where
    PredicateID in (Data.GetPredicateID('WasBornInBrazil'), Data.GetPredicateID('WasBornInArgentina'));

    
  
  


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_WasBornInSovietUnion]()
returns table
as
return
  select
    EntityID
  from
    Data.GetEntityProperties('birthPlace_label')
	where
    Value in (
'Soviet Union',
'Russian Soviet Federative Socialist Republic',
'Ukrainian Soviet Socialist Republic',
'Byelorussian Soviet Socialist Republic',
'Georgian Soviet Socialist Republic',
'Kazakh Soviet Socialist Republic',
'Latvian Soviet Socialist Republic',
'Lithuanian Soviet Socialist Republic',
'Azerbaijan Soviet Socialist Republic',
'Uzbek Soviet Socialist Republic',
'Armenian Soviet Socialist Republic',
'Moldavian Soviet Socialist Republic',
'Kirghiz Soviet Socialist Republic',
'Tajik Soviet Socialist Republic',
'Turkmen Soviet Socialist Republic',
'Abkhaz Autonomous Soviet Socialist Republic',
'Estonian Soviet Socialist Republic',
'Dagestan Autonomous Soviet Socialist Republic',
'ChechenGÇôIngush Autonomous Soviet Socialist Republic',
'Chuvash Autonomous Soviet Socialist Republic',
'Tatar Autonomous Soviet Socialist Republic',
'Nakhchyvan Autonomous Soviet Socialist Republic',
'North Ossetian Autonomous Soviet Socialist Republic',
'Bashkir Autonomous Soviet Socialist Republic',
'Mordovian Autonomous Soviet Socialist Republic',
'Kabardino-Balkar Autonomous Soviet Socialist Republic',
'Mari Autonomous Soviet Socialist Republic',
'Kalmyk Autonomous Soviet Socialist Republic',
'Udmurt Autonomous Soviet Socialist Republic',
'Karelian Autonomous Soviet Socialist Republic',
'Adjar Autonomous Soviet Socialist Republic',
'Komi Autonomous Soviet Socialist Republic',
'Yakut Autonomous Soviet Socialist Republic'
	)


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_WasBornInSpain]()
returns table
as
return
  select
    EntityID
  from
    Data.GetEntityProperties('birthPlace_label')
	where
    Value = 'Spain'


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_WasBornInSweden]()
returns table
as
return
  select
    EntityID
  from
    Data.GetEntityProperties('birthPlace_label')
	where
    Value = 'Sweden'


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_WasBornInTurkey]()
returns table
as
return
  select
    EntityID
  from
    Data.GetEntityProperties('birthPlace_label')
	where
    Value = 'Turkey'


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_WasBornInUnitedKingdomOrIreland]()
returns table
as
return
  select
    EntityID
  from
    Data.GetEntityProperties('birthPlace_label')
	where
    Value in (
		'United Kingdom',
		'United Kingdom of Great Britain and Ireland',
		'England',
		'Scotland',
		'Ireland',
		'Republic of Ireland',
		'Northern Ireland'
	)


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_WasBornInUSA]()
returns table
as
return
  select
    EntityID
  from
    Data.GetEntityProperties('birthPlace_label')
	where
    Value = 'United States'


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function[Data].[Predicate_WasBornInWesternMiddleOrNorthEurope]()
returns table
as
return
  select
    EntityID
  from
    Data.Predicate
  where
    PredicateID in 
      (
        Data.GetPredicateID('WasBornInUnitedKingdomOrIreland'), 
        Data.GetPredicateID('WasBornInGermany'),
        Data.GetPredicateID('WasBornInFrance'), 
        Data.GetPredicateID('WasBornInItaly'), 
        Data.GetPredicateID('WasBornInSpain'), 
        Data.GetPredicateID('WasBornInSweden'), 
        Data.GetPredicateID('WasBornInNetherlands'), 
        Data.GetPredicateID('WasBornInPoland')
      );
