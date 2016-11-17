SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[prGenerateMerge]
    (@table NVARCHAR(128),
     @SourceDB NVARCHAR(128),
      @DestDB NVARCHAR(128))
AS
set nocount on; 
declare @return int;


PRINT '-- ' + @table + ' -------------------------------------------------------------'
--PRINT 'SET NOCOUNT ON;
--'
-- Set the destination database
PRINT 'USE ' + @DestDB
-- Set the identity insert on for tables with identities
select @return = objectproperty(object_id(@table), 'TableHasIdentity')
if @return = 1 
PRINT 'SET IDENTITY_INSERT [dbo].[' + @table + '] ON;
    '


declare @sql varchar(max) = ''
declare @list varchar(max) = '';

SELECT @list = @list + [name] +', '
from sys.columns
where object_id = object_id(@table)


SELECT @list = @list + [name] +', '
from sys.columns
where object_id = object_id(@table)


SELECT @list = @list + 's.' + [name] +', '
from sys.columns
where object_id = object_id(@table)

-- --------------------------------------------------------------------------------
PRINT 'MERGE [dbo].[' + @table + '] AS t'
PRINT 'USING (SELECT * FROM [' + @SourceDB + '].[dbo].[' + @table + '] WITH(NOLOCK)) as s'

-- Get the join columns ----------------------------------------------------------
SET @list = ''
select     @list = @list + 't.[' + c.COLUMN_NAME + '] = s.[' +  c.COLUMN_NAME + '] AND '
from     INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk ,
    INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where     pk.TABLE_NAME = @table
and    CONSTRAINT_TYPE = 'PRIMARY KEY'
and    c.TABLE_NAME = pk.TABLE_NAME
and    c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME

SELECT @list =  LEFT(@list, LEN(@list) -3)
PRINT 'ON ( ' + @list + ')'


-- WHEN MATCHED ------------------------------------------------------------------
PRINT 'WHEN MATCHED THEN UPDATE SET'

SELECT @list = '';
SELECT @list = @list + '    [' + [name] +  '] = s.[' + [name] +'],
'
from sys.columns
where object_id = object_id(@table)
-- don't update primary keys
and [name] NOT IN (SELECT  [column_name]
                    from     INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk ,
                            INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
                    where     pk.TABLE_NAME = @table
                    and    CONSTRAINT_TYPE = 'PRIMARY KEY'
                    and    c.TABLE_NAME = pk.TABLE_NAME
                    and    c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME)
-- and don't update identity columns
and columnproperty(object_id(@table), [name], 'IsIdentity ') = 0                    
--print @list                    
PRINT left(@list, len(@list) -3 )

-- WHEN NOT MATCHED BY TARGET ------------------------------------------------
PRINT ' WHEN NOT MATCHED BY TARGET THEN';

-- Get the insert list
SET @list = ''

SELECT @list = @list + '[' + [name] +'], '
from sys.columns
where object_id = object_id(@table)

SELECT @list = LEFT(@list, LEN(@list) - 1)

PRINT '    INSERT(' + @list + ')'

-- get the values list
SET @list = ''

SELECT @list = @list + 's.[' +[name] +'], '
from sys.columns
where object_id = object_id(@table)

SELECT @list = LEFT(@list, LEN(@list) - 1)

PRINT '    VALUES(' + @list + ')'

-- WHEN NOT MATCHED BY SOURCE
print 'WHEN NOT MATCHED BY SOURCE THEN DELETE; '

-- Set the identity insert OFF for tables with identities
select @return = objectproperty(object_id(@table), 'TableHasIdentity')
if @return = 1 
    PRINT 'SET IDENTITY_INSERT [dbo].[' + @table + '] OFF;
    '
PRINT ''
PRINT 'GO'
PRINT '';

GO
