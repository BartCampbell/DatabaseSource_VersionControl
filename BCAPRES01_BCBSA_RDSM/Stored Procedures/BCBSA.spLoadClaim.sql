SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/****************************************************************************************************************************************************
Purpose:				Create Test Deck for BCBSA Medical Claims-From BCBSA Data
Depenedents:			

Usage					


Change Log:
----------------------------------------------------------------------------------------------------------------------------------------------------- 
2017-03-28	Corey Collins		- Create
2017-03-31	Corey Collins		-Change ClaimInOutPatient to Claim

****************************************************************************************************************************************************/



CREATE PROC [BCBSA].[spLoadClaim]
    @RowCount INT
  , @DestinationTable VARCHAR(100)
AS --uncomment if running manually to test
/*
declare @rowcount int=100
,@DestinationTable varchar(100)='Claim_Tst100'
*/

    DECLARE
        @vcCmd NVARCHAR(MAX)
      , @debug INT = 1;

--drop temp table used to make sure all claimLineItem rows are returned
    SET NOCOUNT ON;
    IF OBJECT_ID('tempdb..#ClaimIDs') IS NOT NULL
        DROP TABLE #ClaimIDs;
--Drop destination Tables
    IF @DestinationTable = 'Claim_Tst100'
        BEGIN 
            IF OBJECT_ID('bcbsa.Claim_Tst100' , 'U') IS NOT NULL
                DROP TABLE BCBSA.Claim_Tst100;
        END;
    IF @DestinationTable = 'Claim_Tst4m'
        BEGIN
            IF OBJECT_ID('bcbsa.Claim_Tst4m' , 'U') IS NOT NULL
                DROP TABLE BCBSA.Claim_Tst4m;
        END;
    IF OBJECT_ID('tempdb..#ClaimIDs') IS NOT NULL
        DROP TABLE #ClaimIDs;
--create temp table used to make sure all claimLineItem rows are returned
    CREATE TABLE #ClaimIDs ( ClaimID INT ); 
 --insert into temp table used to make sure all claimLineItem rows are returned
    SET @vcCmd = '
 insert into #ClaimIDs (ClaimId) 
 select top ' + CAST(@RowCount AS VARCHAR(100)) + ' ClaimId  from IMI_IMIStaging.dbo.Claim ORDER BY DateServiceBegin DESC';
    IF @debug >= 1
        BEGIN 
            PRINT CHAR(13) + 'spLoadClaim: EXEC INSERT INTO #ClaimIds: ' + CHAR(13) + @vcCmd;
  --print @vcCmd
               
 
        END; 
    EXEC (@vcCmd);  

 --Destination table insert
    SET @vcCmd = 'SELECT TOP ' + CAST(@RowCount AS VARCHAR(100)) + '	
cl.RowFileID	
,NULL jobRunTaskFileID	
,NULL LoadInstanceID	
,cl.LoadInstanceFileID	
,c.ClaimID	ClaimNumber
,cl.LineItemNumber	ClaimLineNumber
,NULL AdjustmentSequenceNumber	
,c.ServicingProviderID	ProviderID
,c.BenefitPlanId	ProductID
,c.MemberID	MemberID
,NULL TypeBillCode	
,cl.PlaceOfServiceCode	
,c.ClaimType	ClaimTypeCode
,NULL DRGVersion	
,c.DiagnosisRelatedGroup	DRGCode
,c.DischargeStatus	
,NULL MedicalClass	
,NULL	Denied
,NULL	EpisodeOfIllness
,c.DateAdmitted	AdmitDate
,c.DateDischarged	DischargeDate
,cl.DateServiceBegin	FirstServiceDate
,cl.DateServiceEnd	LastServiceDate
,cl.DateValidBegin	ClaimFromDate
,cl.DateValidEnd	ClaimThroughDate
,cl.DateCheckProcessed	ClaimProcessedDate
,NULL	AdmitCount
,cl.CoveredDays	CoveredDays
,c.ICDCodeType	DiagnosisVersionCode
,NULL	PrimaryDiagnosis
,NULL	PrimaryDiagnosisPOAFlag
,c.AdmittingDiagnosisCode	AdmittingDiagnosis
,NULL	AdmittingDiagnosisPOAFlag
,c.DiagnosisCode1	SecondaryDiagnosisCode1
,c.DiagnosisCode2	SecondaryDiagnosisCode2
,c.DiagnosisCode3	SecondaryDiagnosisCode3
,c.DiagnosisCode4	SecondaryDiagnosisCode4
,c.DiagnosisCode5	SecondaryDiagnosisCode5
,c.DiagnosisCode6	SecondaryDiagnosisCode6
,c.DiagnosisCode7	SecondaryDiagnosisCode7
,c.DiagnosisCode8	SecondaryDiagnosisCode8
,c.DiagnosisCode9	SecondaryDiagnosisCode9
,c.DiagnosisCode10	SecondaryDiagnosisCode10
,c.DiagnosisCode11	SecondaryDiagnosisCode11
,c.DiagnosisCode12	SecondaryDiagnosisCode12
,c.DiagnosisCode13	SecondaryDiagnosisCode13
,c.DiagnosisCode14	SecondaryDiagnosisCode14
,c.DiagnosisCode15	SecondaryDiagnosisCode15
,c.DiagnosisCode16	SecondaryDiagnosisCode16
,c.DiagnosisCode17	SecondaryDiagnosisCode17
,c.DiagnosisCode18	SecondaryDiagnosisCode18
,c.DiagnosisCode19	SecondaryDiagnosisCode19
,c.DiagnosisCode20	SecondaryDiagnosisCode20
,NULL	SecondaryDiagnosisCode21
,NULL	SecondaryDiagnosisCode22
,NULL	SecondaryDiagnosisCode23
,NULL	SecondaryDiagnosisCode24
,c.CustomerPOA1	SecondaryDiagnosis1POAFlag
,c.CustomerPOA2	SecondaryDiagnosis2POAFlag
,c.CustomerPOA3	SecondaryDiagnosis3POAFlag
,c.CustomerPOA4	SecondaryDiagnosis4POAFlag
,c.CustomerPOA5	SecondaryDiagnosis5POAFlag
,c.CustomerPOA6	SecondaryDiagnosis6POAFlag
,c.CustomerPOA7	SecondaryDiagnosis7POAFlag
,c.CustomerPOA8	SecondaryDiagnosis8POAFlag
,c.CustomerPOA9	SecondaryDiagnosis9POAFlag
,c.CustomerPOA10	SecondaryDiagnosis10POAFlag
,c.CustomerPOA11	SecondaryDiagnosis11POAFlag
,c.CustomerPOA12	SecondaryDiagnosis12POAFlag
,NULL	SecondaryDiagnosis13POAFlag
,NULL	SecondaryDiagnosis14POAFlag
,NULL	SecondaryDiagnosis15POAFlag
,NULL	SecondaryDiagnosis16POAFlag
,NULL	SecondaryDiagnosis17POAFlag
,NULL	SecondaryDiagnosis18POAFlag
,NULL	SecondaryDiagnosis19POAFlag
,NULL	SecondaryDiagnosis20POAFlag
,NULL	SecondaryDiagnosis21POAFlag
,NULL	SecondaryDiagnosis22POAFlag
,NULL	SecondaryDiagnosis23POAFlag
,NULL	SecondaryDiagnosis24POAFlag
,c.ICDCodeType	ProcedureVersionCode
,NULL	PrincipalProcedureCode
,NULL	PrincipalProcedureCodeDate
,c.SurgicalProcedure1	OtherProcedureCode1
,c.SurgicalProcedure1Date	OtherProcedureCode1Date
,c.SurgicalProcedure2	OtherProcedureCode2
,c.SurgicalProcedure2Date	OtherProcedureCode2Date
,c.SurgicalProcedure3	OtherProcedureCode3
,c.SurgicalProcedure3Date	OtherProcedureCode3Date
,c.SurgicalProcedure4	OtherProcedureCode4
,c.SurgicalProcedure4Date	OtherProcedureCode4Date
,c.SurgicalProcedure5	OtherProcedureCode5
,c.SurgicalProcedure5Date	OtherProcedureCode5Date
,c.SurgicalProcedure6	OtherProcedureCode6
,c.SurgicalProcedure6Date	OtherProcedureCode6Date
,NULL	OtherProcedureCode7
,NULL	OtherProcedureCode7Date
,NULL	OtherProcedureCode8
,NULL	OtherProcedureCode8Date
,NULL	OtherProcedureCode9
,NULL	OtherProcedureCode9Date
,NULL	OtherProcedureCode10
,NULL	OtherProcedureCode10Date
,NULL	OtherProcedureCode11
,NULL	OtherProcedureCode11Date
,NULL	OtherProcedureCode12
,NULL	OtherProcedureCode12Date
,NULL	OtherProcedureCode13
,NULL	OtherProcedureCode13Date
,NULL	OtherProcedureCode14
,NULL	OtherProcedureCode14Date
,NULL	OtherProcedureCode15
,NULL	OtherProcedureCode15Date
,NULL	OtherProcedureCode16
,NULL	OtherProcedureCode16Date
,NULL	OtherProcedureCode17
,NULL	OtherProcedureCode17Date
,NULL	OtherProcedureCode18
,NULL	OtherProcedureCode18Date
,NULL	OtherProcedureCode19
,NULL	OtherProcedureCode19Date
,NULL	OtherProcedureCode20
,NULL	OtherProcedureCode20Date
,NULL	OtherProcedureCode21
,NULL	OtherProcedureCode21Date
,NULL	OtherProcedureCode22
,NULL	OtherProcedureCode22Date
,NULL	OtherProcedureCode23
,NULL	OtherProcedureCode23Date
,NULL	OtherProcedureCode24
,NULL	OtherProcedureCode24Date
,cl.RevenueCode	RevenueCode
,cl.CPTProcedureCode	LineProcedureCode
,cl.CPTProcedureCodeModifier1	LineProcedureCodeModifier
,cl.CPTProcedureCodeModifier2	LineProcedureCodeModifier2
,cl.CPTProcedureCodeModifier3	LineProcedureCodeModifier3
,cl.CPTProcedureCodeModifier4	LineProcedureCodeModifier4
,cl.Units	Units
,cl.AmountBilled	BilledAmt
,cl.AmountAllowed	AllowedAmt
,NULL	AltAmount1
,NULL	AltAmount2
,NULL	LOINCCode
,NULL	TestResults
,NULL	TestResults2
,cl.NDCCode	NDCCode
,NULL	DrugServiceDate
,NULL	TreatmentLength
,c.DataSource	DataSourceType
,c.SupplementalDataCategory	SupplementalDataSource
,NULL	AuditorApprovedInd
,NULL	AsOfDate

	   into  bcbsa.' + @DestinationTable + ' 
FROM    #ClaimIDs t
INNER JOIN IMI_IMIStaging.dbo.Claim c ON t.ClaimID = c.ClaimID
INNER JOIN IMI_IMIStaging.dbo.ClaimLineItem cl ON c.ClaimID = cl.ClaimID
order by c.DateServiceBegin desc
';

    IF @debug >= 2
        BEGIN 
            PRINT CHAR(13) + 'spLoadClaim: EXEC INSERT INTO Destination Table' + CHAR(13) + @vcCmd;
        END; 
    IF @debug < 2 AND @debug >= 1
        BEGIN
            PRINT CHAR(13) + 'spLoadClaim: Print INSERT INTO Destination Table' + CHAR(13) + @vcCmd;
            EXEC (@vcCmd);
        END; 
			

   
	
	


GO
