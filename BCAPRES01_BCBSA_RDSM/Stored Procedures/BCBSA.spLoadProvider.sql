SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROC [BCBSA].[spLoadProvider]
    @RowCount INT
   ,@DestinationTable VARCHAR(100)
AS --uncomment if running manually to test
/*
declare @Rowcount int=4000000
,@DestinationTable varchar(100)='Provider_Tst4m'
*/

    DECLARE @vcCmd NVARCHAR(MAX)
       ,@debug INT = 1;


--Drop destination Tables
    IF @DestinationTable = 'Provider_Tst100'
        BEGIN 
            IF OBJECT_ID('bcbsa.Provider_Tst100' , 'U') IS NOT NULL
                DROP TABLE bcbsa.Provider_Tst100;
        END;
    IF @DestinationTable = 'Provider_Tst4m'
        BEGIN
            IF OBJECT_ID('bcbsa.Provider_Tst4m' , 'U') IS NOT NULL
                DROP TABLE bcbsa.Provider_Tst4m;
        END;
      

       

 --Destination table insert
    SET @vcCmd = 'SELECT TOP ' + CAST(@rowCount AS VARCHAR(100)) + '	
Null	AltPopID1
,NULL	AltPopID2
,DateRowCreated	AsOfDate
,EIN	GroupID
,NetworkID	IPA
,null	JobRunTaskFileID
,null	LoadInstanceFileID
,null	LoadInstanceID
,ProviderFullName	LocationName
,ProviderType	OfficeType
,null	OMEmail
,null	OMFirstName
,null	OMLastName
,null	OMTitle
,PCPFlag	PCP
,ProviderPrescribingPrivFlag	Prescribing
,null	ProviderAddress1
,null	ProviderAddress2
,null	ProviderCity
,null	ProviderCounty
,null	ProviderCustom1
,null	ProviderCustom2
,null	ProviderCustom3
,null	ProviderCustom4
,null	ProviderEmail
,null	ProviderFAX
,NameFirst	ProviderFirstName
,CustomerProviderID	ProviderID
,NameLast	ProviderLastName
,NameMiddleInitial	ProviderMiddleInitial
,NameSuffix	ProviderNameSuffix
,NPI	ProviderNPI
,null	ProviderState
,null	ProviderTelephone
,null	ProviderZipCode
,null	Region
,null	RowFileID
,DataSource	SourceID
,SpecialtyCode1	TypeID



	   into  bcbsa.' + @DestinationTable + ' 
    FROM IMI_IMIStaging.dbo.Provider  order by dateRowCreated desc
';

    IF @debug >= 2
        BEGIN 
            PRINT CHAR(13)
                + 'spLoadProvider: EXEC INSERT INTO Destination Table'
                + CHAR(13) + @vcCmd;
        END; 
    IF @debug < 2
        AND @debug >= 1
        BEGIN
            PRINT CHAR(13)
                + 'spLoadProvider: Print INSERT INTO Destination Table'
                + CHAR(13) + @vcCmd;
            EXEC (@vcCmd);
        END; 

	
GO
