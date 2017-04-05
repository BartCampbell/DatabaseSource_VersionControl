SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROC [BCBSA].[spLoadEnrollment]
    @RowCount INT
   ,@DestinationTable VARCHAR(100)
AS --uncomment if running manually to test
/*
declare @rowcount int=100
,@DestinationTable varchar(100)='Enrollment_Tst100'
*/

    DECLARE @vcCmd NVARCHAR(MAX)
       ,@debug INT = 1;


--Drop destination Tables
    IF @DestinationTable = 'Enrollment_Tst100'
        BEGIN 
            IF OBJECT_ID('bcbsa.Enrollment_Tst100' , 'U') IS NOT NULL
                DROP TABLE bcbsa.Enrollment_Tst100;
        END;
    IF @DestinationTable = 'Enrollment_Tst4m'
        BEGIN
            IF OBJECT_ID('bcbsa.Enrollment_Tst4m' , 'U') IS NOT NULL
                DROP TABLE bcbsa.Enrollment_Tst4m;
        END;
      

       

 --Destination table insert
    SET @vcCmd = 'SELECT TOP ' + CAST(@rowCount AS VARCHAR(100)) + '	
ProgramID	ProductID
,[MemberID]	MemberID
,[DateEffective]	EnrollmentDate
,[DateTerminated]	TerminationDate
,[BenefitPlanID]	BenefitID
,CustomerPCPID	ProviderID
,[EmployerGroup]	GroupID
,MedicareType	PayerID
,NULL	Confidential
,NULL	TierCode
,NULL	HCFAMarket
,NULL	HCFARateCategory
,NULL	CurrentHealthCondCode
,[CoveragePharmacyFlag]	PharmacyBenefit
,NULL	OutpatientBenefit
,NULL	MentalHealthBenefit
,[CoverageMHInpatientFlag]	MentalHealthINPBenefit
,[CoverageMHAmbulatoryFlag]	MentalHealthAMBBenefit
,[CoverageMHDayNightFlag]	MentalHealthDayNightBenefit
,NULL	ChemDepBenefit
,[CoverageCDInpatientFlag]	ChemDepINPBenefit
,[CoverageCDAmbulatoryFlag]	ChemDepAMBBenefit
,[CoverageCDDayNightFlag]	ChemDepDayNightBenefit
,[CoverageDentalFlag]	DentalBenefit
,[CoverageHospiceFlag]	HospiceBenefit
,NULL	Region
,[InsuredID]	SubscriberID
,NULL	SubscriberRegion
,NULL	AltPopID1
,NULL	AltPopID2
,[PlanID]	CMSPlanID
,[PlanID]	SNPEnrolleeType
,NULL	EnrollmentCustom1
,NULL	EnrollmentCustom2
,NULL	EnrollmentCustom3
,NULL	EnrollmentCustom4
,NULL	ProviderOrganizationID
,NULL	PAProductLine
,NULL	NYProductLine
,NULL	HBXMemberID
,[DateRowCreated]	AsOfDate
,[SourceSystem]	SourceID

	   into  bcbsa.' + @DestinationTable + ' 
FROM     imi_imistaging.dbo.Eligibility
order by dateEffective desc 
';

    IF @debug >= 2
        BEGIN 
            PRINT CHAR(13)
                + 'spLoadEnrollment: EXEC INSERT INTO Destination Table'
                + CHAR(13) + @vcCmd;
        END; 
    IF @debug < 2
        AND @debug >= 1
        BEGIN
            PRINT CHAR(13)
                + 'spLoadEnrollment: Print INSERT INTO Destination Table'
                + CHAR(13) + @vcCmd;
            EXEC (@vcCmd);
        END; 
	
GO
