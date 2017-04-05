SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/****************************************************************************************************************************************************
Purpose:				Map Synonyms for BCBSA FileLoad/Testing
Depenedents:			

Usage					Exec [BCBSA].spMapSynonyms 
							@Debug	
								1 - set debug on
								0 - set debug off
							@Exec 
								1 - execute SQL
								0 - do not exute SQL
							@TargetDB - Target RDSM DB
							@TargetSchema Target RDSM Schema

Test
	exec RDSM.spMapSynonyms
		@Debug = 1,
		@Exec  = 1,
		@TargetDB ='BCBSA_RDSM',
		@TargetSchema = 'BCBSA_GDIT2017'
	
Change Log:
----------------------------------------------------------------------------------------------------------------------------------------------------- 
2017-03-28	Corey Collins		- Create
2017-03-30	Corey Collins		--Account for TestDeck Schema
2017-03-30	Corey Collins		--Add TargetDB per VLK/Leon
2017-03-30  Leon				--Change for staging
2017-03-31	CC					--Change ClaimInOutPatient to Claim
****************************************************************************************************************************************************/
--/*
CREATE PROC [RDSM].[spMapSynonyms]
    (	@Debug BIT= 1,
		@Exec BIT = 0,
		@TargetDB varchar(100),
		@TargetSchema VARCHAR(100)
    )
AS
SET NOCOUNT ON;  
--*/

    --uncomment for manual test
   /*
	DECLARE 
		@Debug BIT= 1,
		@Exec BIT = 1,
		@TargetDB varchar(100)='BCBSA_RDSM',
		@TargetSchema VARCHAR(100)= 'BCBSA_GDIT2017'
	--*/
		  
DECLARE @SQL NVARCHAR(MAX),
    @SynonymName VARCHAR(255),
    @SynonymTarget VARCHAR(255),
    @BaseTableName VARCHAR(255)
    
DECLARE @TableNames TABLE
    (TableName VARCHAR(255),
     Used INT
    )

INSERT INTO @TableNames
        (TableName)
    SELECT 'Enrollment'
    UNION SELECT 'ExternalEvent'
    UNION SELECT 'GroupPlan'
    UNION SELECT 'Member'
	UNION SELECT 'Provider'
    UNION SELECT 'ProviderSpecialty'
	UNION SELECT 'RxClaim'
    UNION SELECT 'Claim'
    UNION SELECT 'ClamLab'

SELECT @BaseTableName = MIN(TableName)
    FROM @TableNames

WHILE @BaseTableName IS NOT NULL
BEGIN 
		
	--Populate the Synoynm Target and Synonym Name variables to create/drop them
    SELECT @SynonymTarget = @TargetSchema + '.' + @BaseTableName

    SELECT @SynonymName = 'RDSM.' + @BaseTableName  

	--Drop Synonyms if they exist
    IF OBJECT_ID(@SynonymName) IS NOT NULL 
	BEGIN
		SET @SQL = 'DROP SYNONYM ' + @SynonymName

		IF @Debug = 1
			PRINT 'spMapSynonyms: Drop Synonyms ' + @SQL;
		IF @Exec = 1
			EXECUTE (@SQL)
	END 

	--CREATE the Synonyms
    SELECT @SQL = 'CREATE SYNONYM ' + @SynonymName 
					+ ' FOR ' + @TargetDB + '.' + @SynonymTarget

	IF @Debug = 1
        PRINT 'spMapSynonyms: Create Synonyms ' + @SQL;
	IF @Exec = 1
		EXECUTE (@SQL)

	--update loop table
	SELECT @BaseTableName = MIN(TableName)
	    FROM @TableNames
		WHERE TableName > @BaseTableName

END
           
GO
