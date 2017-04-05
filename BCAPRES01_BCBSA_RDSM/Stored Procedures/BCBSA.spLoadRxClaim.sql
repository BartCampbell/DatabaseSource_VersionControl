SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROC [BCBSA].[spLoadRxClaim]
    @RowCount INT
   ,@DestinationTable VARCHAR(100)
AS --uncomment if running manually to test
/*
declare @Rowcount int=100
,@DestinationTable varchar(100)='RxClaim_Tst100'
*/

    DECLARE @vcCmd NVARCHAR(MAX)
       ,@debug INT = 1;


--Drop destination Tables
    IF @DestinationTable = 'RxClaim_Tst100'
        BEGIN 
            IF OBJECT_ID('bcbsa.RxClaim_Tst100' , 'U') IS NOT NULL
                DROP TABLE bcbsa.RxClaim_Tst100;
        END;
    IF @DestinationTable = 'RxClaim_Tst4m'
        BEGIN
            IF OBJECT_ID('bcbsa.RxClaim_Tst4m' , 'U') IS NOT NULL
                DROP TABLE bcbsa.RxClaim_Tst4m;
        END;
      

       

 --Destination table insert
    SET @vcCmd = 'SELECT TOP ' + CAST(@rowCount AS VARCHAR(100)) + '	
CostCoveredPlanAmountTotalPaid	AllowedAmt
,DateRowCreated	AsOfDate
,NULL	AuditorApprovedInd
,ClaimSequenceNumber	ClaimLineNumber
,ClaimNumber	ClaimNumber
,DrugTherapeuticClass	ClassCategoryCode
,SourceSystem	DataSourceType
,ClaimStatusCode	Denied
,DateDispensed	DispenseDate
,ihds_prov_id_dispensing	DispensingProv
,NULL	EpisodeOfIllness
,null	JobRunTaskFileID
,null	LoadInstanceFileID
,null	LoadInstanceID
,MemberID	MemberID
,Quantity	MetricQuantity
,NDC	NDCCode
,DateOrdered	PrescribedDate
,PrescribingProviderID	PrescribingProv
,NULL	ProductID
,QuantityDispensed	QuantityDispensed
,RefillNumber	RefillCounta
,NULL	RxClaimCount
,DataSource	SourceID
,SupplementalDataCode	SupplementalDataSource
,DaysSupply	SupplyDays
,RowFileID	RowFileID





	   into  bcbsa.' + @DestinationTable + ' 
    From IMI_IMIStaging.dbo.PharmacyClaim
  order by DateDispensed desc
';

    IF @debug >= 2
        BEGIN 
            PRINT CHAR(13)
                + 'spLoadRxClaim: EXEC INSERT INTO Destination Table'
                + CHAR(13) + @vcCmd;
        END; 
    IF @debug < 2
        AND @debug >= 1
        BEGIN
            PRINT CHAR(13)
                + 'spLoadRxClaim: Print INSERT INTO Destination Table'
                + CHAR(13) + @vcCmd;
            EXEC (@vcCmd);
        END; 
		
	
GO
