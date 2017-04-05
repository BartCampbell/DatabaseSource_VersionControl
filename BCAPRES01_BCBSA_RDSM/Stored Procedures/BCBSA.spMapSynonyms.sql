SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/****************************************************************************************************************************************************
Purpose:				Map Synonyms for BCBSA FileLoad/Testing
Depenedents:			

Usage					Exec [BCBSA].spMapSynonyms @TestDeck
													=1 map to TestDeck_ Schema +_+@TestDeckSize (i.e. TestDeck100.RxClaim)
													=0 map to @TargetSchema + base table (i.e. BCBSA_GDIT.RxClaim)
												  ,@TestDeckSize=100 (NULL if not TestDeck)
												  ,@TargetSchema= 'BCBSA_GDIT2017' (NULL if TestDeck)
												  ,@Debug= 
													0:Exec with no Debug 
													1:Exec with Debug 
													2:Debug Print Only




Change Log:
----------------------------------------------------------------------------------------------------------------------------------------------------- 
2017-03-28	Corey Collins		- Create
2017-03-30	Corey Collins		--Account for TestDeck Schema

****************************************************************************************************************************************************/

CREATE PROC [BCBSA].[spMapSynonyms]
    (
     @TestDeck INT
    ,@TestDeckSize VARCHAR(100) NULL
     
	,@TargetSchema VARCHAR(100) NULL
	,@Debug int 
    )
AS
    SET NOCOUNT ON;  

   /* --uncomment for manual test
   DECLARE @TestDeckSize VARCHAR(100)= 100
       ,@TestDeck INT= 1
       ,@TargetSchema VARCHAR(100)= 'BCBSA_GDIT2017'
	      ,@Debug INT= 1;*/

		  
       Declare @SQL NVARCHAR(MAX)
       ,@SynonymName VARCHAR(255)
       ,@SynonymTarget VARCHAR(255)
       ,@BaseTableName VARCHAR(255)
    
    DECLARE @TableNames TABLE
        (
         TableName VARCHAR(255)
        ,Used INT
        );
    INSERT  INTO @TableNames
            ( TableName , Used )
    SELECT  'Enrollment'
           ,0;
    INSERT  INTO @TableNames
            ( TableName , Used )
    SELECT  'ExternalEvent'
           ,0;
    INSERT  INTO @TableNames
            ( TableName , Used )
    SELECT  'GroupPlan'
           ,0;
    INSERT  INTO @TableNames
            ( TableName , Used )
    SELECT  'Member'
           ,0;
    INSERT  INTO @TableNames
            ( TableName , Used )
    SELECT  'Provider'
           ,0;
    INSERT  INTO @TableNames
            ( TableName , Used )
    SELECT  'ProviderSpecialty'
           ,0;
    INSERT  INTO @TableNames
            ( TableName , Used )
    SELECT  'RxClaim'
           ,0;
    SELECT DISTINCT
            @BaseTableName = TableName
    FROM    @TableNames

    WHERE   Used = 0;
	INSERT  INTO @TableNames
            ( TableName , Used )
    SELECT  'Claim'
           ,0;
		   INSERT  INTO @TableNames
            ( TableName , Used )
    SELECT  'ClamLab'
           ,0;
    SELECT DISTINCT
            @BaseTableName = TableName
    FROM    @TableNames
    WHERE   Used = 0;
    WHILE @BaseTableName IS NOT NULL
        BEGIN 

--Populate the Synoynm Target and Synonym Name variables to create/drop them
            SELECT  @SynonymTarget = CASE WHEN @TestDeck = 1
                                          THEN 'Test' + @TestDeckSize + '.'
                                               + @BaseTableName
                                          ELSE @TargetSchema + '.'
                                               + @BaseTableName
                                     END;  --print @synonymTarget print @BaseTableName
					   
            SELECT  @SynonymName = 'BCBSA.' + @BaseTableName;  

--Drop Synonyms if they exist
	   
            SET @SQL = '

			  IF EXISTS ( SELECT
                                            *
                                          FROM
                                            sys.synonyms
                                          WHERE
                                            name = ''' + REPLACE(@SynonymName ,
                                                              'BCBSA.' , '')
                + ''')
                                 DROP SYNONYM ' + @SynonymName + '';
             IF @Debug = 0
				Begin 
                EXECUTE sp_executesql @SQL;
				End 
            IF @Debug = 1
			Begin 

                PRINT 'spMapSynonyms: Drop Synonyms ' + @SQL;
            EXECUTE sp_executesql @SQL;
          End 
		    IF @Debug = 2
			Begin
                PRINT 'spMapSynonyms: Drop Synonyms ' + @SQL;
				End 

--CREATE the Synonyms
 
            SET @SQL = ( SELECT 'CREATE SYNONYM ' + @SynonymName + ' FOR '
                                + @SynonymTarget
                       );
            IF @Debug = 0
				Begin 
                EXECUTE sp_executesql @SQL;
				End 
            IF @Debug = 1
			Begin 

                PRINT 'spMapSynonyms: Create Synonyms ' + @SQL;
            EXECUTE sp_executesql @SQL;
          End 
		    IF @Debug = 2
			Begin
                PRINT 'spMapSynonyms: Create Synonyms ' + @SQL;
				End 

           
			

--update loop table

  
            UPDATE  c
            SET     c.Used = 1
            FROM    @TableNames c
            WHERE   c.TableName = @BaseTableName;
                   
--reset @BaseTableName variable
            SET @BaseTableName = NULL; 
         
        
--set variables for next round of the loop 
            SELECT  @BaseTableName = TableName
            FROM    @TableNames
            WHERE   Used = 0;
        END;
	

								 



 

                        
           
                    
GO
