SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[spMergeTable]
    (
      @pSourceDB VARCHAR(255) = NULL ,
      @pTargetDB AS VARCHAR(255) = NULL ,
      @pSourceSchema AS VARCHAR(255) = 'dbo' ,
	 @pTargetSchema AS VARCHAR (255) = 'dbo' ,
      @pSourceTableName AS VARCHAR(255) = NULL ,
      @pTargetTableName AS VARCHAR(255) = NULL ,
      --@pLinkedServer AS NVARCHAR(255) = NULL ,
      --@pDomain AS NVARCHAR(255) = NULL ,
      @pDisableTriggers BIT = 0 ,
      --@pRemoveLinkedServer BIT = 0 ,
      @pEXECUTE BIT = 0 ,
      @pDebug BIT = 0
    )
AS
    DECLARE @SourceDB VARCHAR(255) = QUOTENAME(@pSourceDB) ,
        @TargetDB AS VARCHAR(255) = QUOTENAME(@pTargetDB) ,
        @SourceSchema AS VARCHAR(255) = QUOTENAME(@pSourceSchema) ,
	   @TargetSchema AS VARCHAR(255) = QUOTENAME(@pTargetSchema) ,
        @SourceTableName AS VARCHAR(255) = @pSourceTableName ,
        @TargetTableName AS VARCHAR(255) = @pTargetTableName ,
        --@LinkedServer AS NVARCHAR(255) = QUOTENAME(@pLinkedServer) , /*If a server is supplied it will be added if it doesn't already exist*/
        --@Domain AS NVARCHAR(255) = @pDomain , /*If you want to create your linked server with a FQDN as a datasource, which I recommend*/
        @DisableTriggers BIT = @pDisableTriggers ,
        --@RemoveLinkedServer BIT = @pRemoveLinkedServer ,
        @EXECUTE BIT = @pEXECUTE ,
        @Debug BIT = @pDebug;
    
    DECLARE @Tables TABLE ( TableName VARCHAR(MAX) );
    DECLARE @Columns TABLE
        (
          ColId INT ,
          ColumnName VARCHAR(MAX)
        );
    DECLARE @ColumnList AS VARCHAR(MAX);
    DECLARE @UnequalList AS VARCHAR(MAX);
    DECLARE @EqualList AS VARCHAR(MAX);
    DECLARE @InsertList AS VARCHAR(MAX);
    DECLARE @SQL AS VARCHAR(MAX);
    DECLARE @IdCol AS TABLE ( IdCol VARCHAR(100) );

    DECLARE @FQTNSource AS VARCHAR(500);  
    --SELECT  @FQTNSource = CASE WHEN @LinkedServer IS NOT NULL THEN @LinkedServer + '.'
    --                           ELSE ''
    --                      END + @SourceDB + '.' + @SourceSchema + '.' + QUOTENAME(@SourceTableName);
    SELECT  @FQTNSource = @SourceDB + '.' + @SourceSchema + '.' + QUOTENAME(@SourceTableName);

    DECLARE @FQTNTarget AS VARCHAR(500);  
    SELECT  @FQTNTarget = @TargetDB + '.' + @TargetSchema + '.' + QUOTENAME(@TargetTableName);
	
    DECLARE @MatchColumns AS TABLE
        (
          ColumnName VARCHAR(100)
        );
    DECLARE @MatchOnList AS VARCHAR(MAX);

    SET NOCOUNT ON;

/*Create linked server var without brackets to properly add or remove the linked server*/
    --DECLARE @LinkedServerNoBracket AS VARCHAR(255) = REPLACE(REPLACE(@LinkedServer, ']', ''), '[', '');
    --DECLARE @DataSource AS VARCHAR(255) = @LinkedServerNoBracket + @Domain;

 --   IF NOT EXISTS ( SELECT  [sysadmin]
 --                   FROM    syslogins
 --                   WHERE   sysadmin = 1
 --                           AND hasaccess = 1
 --                           AND [name] = SYSTEM_USER )
 --       BEGIN
 --           PRINT 'User must be sysAdmin to add Linked Servers';
 --       END;
 --   ELSE
 --       BEGIN  	
	--/*Create Linked server*/
 --           IF @LinkedServer IS NOT NULL
 --               AND NOT EXISTS ( SELECT srv.name
 --                                FROM   sys.servers srv
 --                                WHERE  srv.server_id != 0
 --                                       AND srv.name = @LinkedServerNoBracket )
 --               BEGIN

 --                   EXEC master.dbo.sp_addlinkedserver @server = @LinkedServerNoBracket, @srvproduct = N'', @provider = N'SQLNCLI', @datasrc = @DataSource;

 --                   EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = @LinkedServerNoBracket, @locallogin = NULL, @useself = N'True';

 --                   PRINT 'Created Linked Server';
 --               END;
 --       END;
    
    -- init working table
    DELETE  FROM @Columns;
    
    -- get list of columns in the table. Exclude the timestamp column
    SET @SQL = 'SELECT	ORDINAL_POSITION  , COLUMN_NAME FROM ' + @SourceDB + '.' + 'INFORMATION_SCHEMA.COLUMNS c INNER JOIN '
        + @SourceDB + '.[sys].[columns] AS C1 ON OBJECT_NAME([C1].[object_id]) = ''' + @SourceTableName
        + ''' AND c1.[name] = [c].[COLUMN_NAME] WHERE TABLE_NAME = ''' + @SourceTableName
        + ''' AND DATA_TYPE != ''Timestamp'' AND [C1].[is_computed] = 0 ORDER BY 	ORDINAL_POSITION';  

    IF @Debug = 1
        BEGIN
            PRINT @SQL;
        END;

    INSERT  @Columns
            EXECUTE ( @SQL
                   );

    -- get the table identity column to link the source to the target
    DELETE  @IdCol;
    SELECT  @SQL = 'SELECT [name] FROM ' + @SourceDB + '.' + 'SYS.IDENTITY_COLUMNS WHERE OBJECT_NAME(OBJECT_ID) = ''' + @TargetTableName + '''';

    IF @Debug = 1
        BEGIN
            PRINT @SQL;
        END;	

    INSERT  @IdCol
            EXEC ( @SQL
                );

    SET @MatchOnList = NULL;
    SELECT  @MatchOnList = 'T.' + [IdCol] + ' = S.' + [IdCol]
    FROM    @IdCol;

    IF @Debug = 1
        BEGIN
            PRINT 'Match List: ' + ISNULL(@MatchOnList, 'Empty');
        END;
    
    -- if there is an identity column use it, but if not then look for primary keys
    IF ( @MatchOnList IS NULL )
        BEGIN
            SET @SQL = 'SELECT u.column_name FROM ' + @SourceDB + '.' + 'information_schema.key_column_usage u inner join '
                + @SourceDB + '.' + 'INFORMATION_SCHEMA.TABLE_CONSTRAINTS c on c.CONSTRAINT_NAME = u.CONSTRAINT_NAME WHERE c.TABLE_NAME = '''
                + @SourceTableName + '''and c.CONSTRAINT_TYPE=''Primary Key'' order by u.ORDINAL_POSITION';
            INSERT  @MatchColumns
                    EXECUTE ( @SQL
                           );
            SELECT  @MatchOnList = COALESCE(@MatchOnList + ' AND T.[' + ColumnName + '] = S.[' + ColumnName + ']',
                                            'T.[' + ColumnName + '] = S.[' + ColumnName + ']')
            FROM    @MatchColumns; 

            IF @Debug = 1
                BEGIN
                    PRINT 'Match List: ' + ISNULL(@MatchOnList, 'Empty');
                END;
    
            IF ( @MatchOnList IS NULL )
                BEGIN
                    SET @MatchOnList = 'T.<TargetColumnName> = S.<SourceColumnName>';
                    PRINT 'User Must Supply columns to match upon';
                END;
        END;
    
    -- coalesce the columns
    SET @ColumnList = NULL;
    SELECT  @ColumnList = COALESCE(@ColumnList + ', [' + ColumnName + ']', '[' + ColumnName + ']')
    FROM    @Columns
    ORDER BY ColId;
	
    IF @Debug = 1
        BEGIN
            PRINT 'Column List: ' + ISNULL(@ColumnList, 'Empty');
        END;
    -- coalesce the unequal columns (used to locate changes)
    SET @UnequalList = NULL;
    SELECT  @UnequalList = COALESCE(@UnequalList + ' or T.[' + c.ColumnName + '] != S.[' + c.ColumnName + ']',
                                    'T.[' + c.ColumnName + '] != S.[' + c.ColumnName + ']')
    FROM    @Columns c
            LEFT OUTER JOIN @IdCol i ON c.ColumnName = i.IdCol
    WHERE   i.IdCol IS NULL;

    IF @Debug = 1
        BEGIN
            PRINT 'UnEqual List: ' + ISNULL(@UnequalList, 'Empty');
        END;
    -- coalesce the equal columns (used to update the target)
    SET @EqualList = NULL;
    SELECT  @EqualList = COALESCE(@EqualList + ', T.[' + c.ColumnName + '] = S.[' + c.ColumnName + ']', 'T.[' + c.ColumnName + '] = S.[' + c.ColumnName + ']')
    FROM    @Columns c
            LEFT OUTER JOIN @IdCol i ON c.ColumnName = i.IdCol
    WHERE   i.IdCol IS NULL;

    IF @Debug = 1
        BEGIN
            PRINT 'Equal List: ' + ISNULL(@EqualList, 'Empty');
        END;
    
    -- coalesce the insert columns (used to insert the target)
    SET @InsertList = NULL;
    SELECT  @InsertList = COALESCE(@InsertList + ', S.[' + ColumnName + ']', 'S.[' + ColumnName + ']')
    FROM    @Columns;

    IF @Debug = 1
        BEGIN
            PRINT 'Insert List: ' + ISNULL(@InsertList, 'Empty');
        END;
    
    SET NOCOUNT OFF;
-- now output the statement
/*Clear out variable to hold merge statement*/
    SELECT  @SQL = '';

    IF @DisableTriggers = 1
        BEGIN
            SELECT  @SQL = @SQL + 'DISABLE TRIGGER ALL ON ' + QUOTENAME(@TargetTableName) + CHAR(13) + CHAR(10);
            SELECT  @SQL = @SQL + '' + CHAR(13) + CHAR(10);
        END;

/*Put SQL in variable*/
    IF EXISTS ( SELECT  [IdCol]
                FROM    @IdCol )
        BEGIN
            SELECT  @SQL = @SQL + 'SET IDENTITY_INSERT ' + @TargetDB + '.' + @TargetSchema + '.' + QUOTENAME(@TargetTableName) + ' ON' + CHAR(13) + CHAR(10);
            SELECT  @SQL = @SQL + '' + CHAR(13) + CHAR(10);
        END;

    SELECT  @SQL = @SQL + ' MERGE INTO ' + @TargetDB + '.[dbo].[' + @TargetTableName + '] as T' + CHAR(13) + CHAR(10);
    SELECT  @SQL = @SQL + ' USING ' + @FQTNSource + ' as S' + CHAR(13) + CHAR(10);
    SELECT  @SQL = @SQL + ' ON ' + @MatchOnList + CHAR(13) + CHAR(10);
    SELECT  @SQL = @SQL + ' WHEN MATCHED AND ' + @UnequalList + CHAR(13) + CHAR(10);
    SELECT  @SQL = @SQL + ' THEN UPDATE SET ' + @EqualList + CHAR(13) + CHAR(10);
    SELECT  @SQL = @SQL + ' WHEN NOT MATCHED BY TARGET' + CHAR(13) + CHAR(10);
    SELECT  @SQL = @SQL + ' THEN INSERT (' + @ColumnList + ')' + CHAR(13) + CHAR(10);
    SELECT  @SQL = @SQL + ' VALUES (' + @InsertList + ')' + CHAR(13) + CHAR(10);
    SELECT  @SQL = @SQL + ' WHEN NOT MATCHED BY SOURCE' + CHAR(13) + CHAR(10);
    SELECT  @SQL = @SQL + ' THEN DELETE;' + CHAR(13) + CHAR(10);

    IF EXISTS ( SELECT  [IdCol]
                FROM    @IdCol )
        BEGIN
            SELECT  @SQL = @SQL + '' + CHAR(13) + CHAR(10);
            SELECT  @SQL = @SQL + ' SET IDENTITY_INSERT ' + @TargetDB + '.' + @TargetSchema + '.' + QUOTENAME(@TargetTableName) + ' OFF';
        END; 

    IF @DisableTriggers = 1
        BEGIN
            SELECT  @SQL = @SQL + 'ENABLE TRIGGER ALL ON ' + QUOTENAME(@TargetTableName) + CHAR(13) + CHAR(10);
            SELECT  @SQL = @SQL + '' + CHAR(13) + CHAR(10);
        END;

    SELECT  @SQL; 

    IF @EXECUTE = 1
        BEGIN


    
	/*Execute Merge*/
            EXEC(@SQL);

	/*Remove Linked Server*/
            --IF @RemoveLinkedServer = 1
            --    BEGIN
            --        IF NOT EXISTS ( SELECT  [sysadmin]
            --                        FROM    syslogins
            --                        WHERE   sysadmin = 1
            --                                AND hasaccess = 1
            --                                AND [name] = SYSTEM_USER )
            --            BEGIN
            --                PRINT 'User must be sysAdmin to add Linked Servers';
            --            END;
            --        ELSE
            --            BEGIN
            --                IF EXISTS ( SELECT  srv.name
            --                            FROM    sys.servers srv
            --                            WHERE   srv.server_id != 0
            --                                    AND srv.name = @LinkedServerNoBracket )
            --                    EXEC master.dbo.sp_dropserver @server = @LinkedServerNoBracket, @droplogins = 'droplogins';
            --                PRINT 'Linked Server Removed'; 
            --            END;                                      
            --    END;
        END;   
GO
