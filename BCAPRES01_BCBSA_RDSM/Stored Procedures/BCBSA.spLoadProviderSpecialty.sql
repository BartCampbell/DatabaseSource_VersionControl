SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROC [BCBSA].[spLoadProviderSpecialty]
    @RowCount INT
   ,@DestinationTable VARCHAR(100)
AS --uncomment if running manually to test
/*
declare @Rowcount int=100
,@DestinationTable varchar(100)='ProviderSpecialty_Tst100'
*/

    DECLARE @vcCmd NVARCHAR(MAX)
       ,@debug INT = 1;


--Drop destination Tables
    IF @DestinationTable = 'ProviderSpecialty_Tst100'
        BEGIN 
            IF OBJECT_ID('bcbsa.ProviderSpecialty_Tst100' , 'U') IS NOT NULL
                DROP TABLE bcbsa.ProviderSpecialty_Tst100;
        END;
    IF @DestinationTable = 'ProviderSpecialty_Tst4m'
        BEGIN
            IF OBJECT_ID('bcbsa.ProviderSpecialty_Tst4m' , 'U') IS NOT NULL
                DROP TABLE bcbsa.ProviderSpecialty_Tst4m;
        END;
      

       

 --Destination table insert
    SET @vcCmd = 'SELECT TOP ' + CAST(@rowCount AS VARCHAR(100)) + '	
null	RowFileID
,null	JobRunTaskFileID
,null	LoadInstanceID
,null	LoadInstanceFileID
,ProviderID	ProviderID
,SpecialtyID	ProviderSpecialtyID
,null	PHSpecialtyID
,null	PrimarySpecialty
,DataSource	SourceID




	   into  bcbsa.' + @DestinationTable + ' 
    FROM IMI_IMIStaging.dbo.ProviderSpecialty  order by ProviderSpecialtyID asc
';

    IF @debug >= 2
        BEGIN 
            PRINT CHAR(13)
                + 'spLoadProviderSpecialty: EXEC INSERT INTO Destination Table'
                + CHAR(13) + @vcCmd;
        END; 
    IF @debug < 2
        AND @debug >= 1
        BEGIN
            PRINT CHAR(13)
                + 'spLoadProviderSpecialty: Print INSERT INTO Destination Table'
                + CHAR(13) + @vcCmd;
            EXEC (@vcCmd);
        END; 
		

	
GO
