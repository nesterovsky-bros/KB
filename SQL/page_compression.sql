-- Run this script after script.sql.
-- This script changes type compression of tables to PAGE;
-- this greatly reduces the size of the database, and even boosts the performance.
-- Unfortunately not every SQL Server edition supports this.

ALTER TABLE [Data].[PropertyType] REBUILD PARTITION = ALL WITH(DATA_COMPRESSION = PAGE)
GO

ALTER TABLE [Data].[PredicateType] REBUILD PARTITION = ALL WITH(DATA_COMPRESSION = PAGE)
GO

ALTER TABLE [Data].[Entity] REBUILD PARTITION = ALL WITH(DATA_COMPRESSION = PAGE)
GO

ALTER TABLE [Data].[Property] REBUILD PARTITION = ALL WITH(DATA_COMPRESSION = PAGE)
GO

ALTER TABLE [Data].[Predicate] REBUILD PARTITION = ALL WITH(DATA_COMPRESSION = PAGE)
GO

ALTER TABLE [Data].[PredicateTree] REBUILD PARTITION = ALL WITH(DATA_COMPRESSION = PAGE)
GO
