SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[prClaimsStageRawMerge]
	-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

MERGE CHSStaging.[dbo].Claims_Stage_Raw AS t
USING (SELECT * FROM [CCAI_Claims_Export].[dbo].[CCAIClaimDetailExtract] WITH(NOLOCK)) as s
ON ( t.[SequenceNumber] = s.[SequenceNumber] )
WHEN MATCHED THEN UPDATE SET
    [Claim Number] = s.[Claim Number],
    [Member ID#] = s.[Member ID#],
    [Member First Name] = s.[Member First Name],
    [Member Last Name] = s.[Member Last Name],
    [DOB] = s.[DOB],
    [Gender] = s.[Gender],
    [Claim Status] = s.[Claim Status],
    [POS] = s.[POS],
    [TOS] = s.[TOS],
    [TOB] = s.[TOB],
    [HRC] = s.[HRC],
    [From Date] = s.[From Date],
    [To Date] = s.[To Date],
    [CPT] = s.[CPT],
    [Modifier1] = s.[Modifier1],
    [Modifier2] = s.[Modifier2],
    [Modifier3] = s.[Modifier3],
    [Modifier4] = s.[Modifier4],
    [Units] = s.[Units],
    [Amount Billed] = s.[Amount Billed],
    [Allowed Charge] = s.[Allowed Charge],
    [Copay] = s.[Copay],
    [Coinsurance] = s.[Coinsurance],
    [Total Allowed] = s.[Total Allowed],
    [Amount Paid] = s.[Amount Paid],
    [DOR] = s.[DOR],
    [DOP] = s.[DOP],
    [Adjudication Code] = s.[Adjudication Code],
    [Adjudication Code Description] = s.[Adjudication Code Description],
    [Authorization Number] = s.[Authorization Number],
    [Referral Number] = s.[Referral Number],
    [Check Number] = s.[Check Number],
    [Rendering Provider #] = s.[Rendering Provider #],
    [Rendering Provider Last] = s.[Rendering Provider Last],
    [Rendering Provider First] = s.[Rendiering Provider First],
    [Rendering Provider Network Status] = s.[Rendering Provider Network Status],
    [Rendering Provider Facility Status] = s.[Rendering Provider Facility Status],
    [Rendering Provider NPI] = s.[Rendering Provider NPI],
    [Rendering Provider Specialty Code] = s.[Rendering Provider Specialty Code],
    [Rendering Provider Specialty] = s.[Rendering Provider Specialty],
    [Tax ID#] = s.[Tax ID#],
    [Box 32 Name] = s.[Box 32 Name],
    [Box 32 Street] = s.[Box 32 Street],
    [Box 32 Street 2] = s.[Box 32 Street 2],
    [Box 32 City] = s.[Box 32 City],
    [Box 32 State] = s.[Box 32 State],
    [Box 32 Zip] = s.[Box 32 Zip],
    [Box 33 Payee Provider #] = s.[Box 33 Payee Provider #],
    [Box 33 Payee Provider Last] = s.[Box 33 Payee Provider Last],
    [Box 33 Payee Provider First] = s.[Box 33 Payee Provider First],
    [Box 33 Payee Provider NPI] = s.[Box 33 Payee Provider NPI],
    [Box 33 Payee Provider Address Type] = s.[Box 33 Payee Provider Address Type],
    [Box 33 Payee Provider Street] = s.[Box 33 Payee Provider Street],
    [Box 33 Payee Provider Street 2] = s.[Box 33 Payee Provider Street 2],
    [Box 33 Payee Provider City] = s.[Box 33 Payee Provider City],
    [Box 33 Payee Provider State] = s.[Box 33 Payee Provider State],
    [Box 33 Payee Provider Zip] = s.[Box 33 Payee Provider Zip],
    [PCP Provider #] = s.[PCP Provider #],
    [PCP Last] = s.[PCP Last],
    [PCP First] = s.[PCP First],
    [LineItemControlNumber] = s.[LineItemControlNumber],
    [Claimtype] = s.[Claimtype],
    [DischargeStatus] = s.[DischargeStatus],
    [AdmissionDate] = s.[AdmissionDate],
    [DischargeDate] = s.[DischargeDate],
    [AdmissionSourceCode] = s.[AdmissionSourceCode],
    [Payor] = s.[Payor]
 WHEN NOT MATCHED BY TARGET THEN
    INSERT([Claim Number], [Member ID#], [Member First Name], [Member Last Name], [DOB], [Gender], [Claim Status], [POS], [TOS], [TOB], [HRC], [From Date], [To Date], [CPT], [Modifier1], [Modifier2], [Modifier3], [Modifier4], [Units], [Amount Billed], [Allowed Charge], [Copay], [Coinsurance], [Total Allowed], [Amount Paid], [DOR], [DOP], [Adjudication Code], [Adjudication Code Description], [Authorization Number], [Referral Number], [Check Number], [Rendering Provider #], [Rendering Provider Last], [Rendering Provider First], [Rendering Provider Network Status], [Rendering Provider Facility Status], [Rendering Provider NPI], [Rendering Provider Specialty Code], [Rendering Provider Specialty], [Tax ID#], [Box 32 Name], [Box 32 Street], [Box 32 Street 2], [Box 32 City], [Box 32 State], [Box 32 Zip], [Box 33 Payee Provider #], [Box 33 Payee Provider Last], [Box 33 Payee Provider First], [Box 33 Payee Provider NPI], [Box 33 Payee Provider Address Type], [Box 33 Payee Provider Street], [Box 33 Payee Provider Street 2], [Box 33 Payee Provider City], [Box 33 Payee Provider State], [Box 33 Payee Provider Zip], [PCP Provider #], [PCP Last], [PCP First], [SequenceNumber], [LineItemControlNumber], [Claimtype], [DischargeStatus], [AdmissionDate], [DischargeDate], [AdmissionSourceCode], [Payor])
    VALUES(s.[Claim Number], s.[Member ID#], s.[Member First Name], s.[Member Last Name], s.[DOB], s.[Gender], s.[Claim Status], s.[POS], s.[TOS], s.[TOB], s.[HRC], s.[From Date], s.[To Date], s.[CPT], s.[Modifier1], s.[Modifier2], s.[Modifier3], s.[Modifier4], s.[Units], s.[Amount Billed], s.[Allowed Charge], s.[Copay], s.[Coinsurance], s.[Total Allowed], s.[Amount Paid], s.[DOR], s.[DOP], s.[Adjudication Code], s.[Adjudication Code Description], s.[Authorization Number], s.[Referral Number], s.[Check Number], s.[Rendering Provider #], s.[Rendering Provider Last], s.[Rendiering Provider First], s.[Rendering Provider Network Status], s.[Rendering Provider Facility Status], s.[Rendering Provider NPI], s.[Rendering Provider Specialty Code], s.[Rendering Provider Specialty], s.[Tax ID#], s.[Box 32 Name], s.[Box 32 Street], s.[Box 32 Street 2], s.[Box 32 City], s.[Box 32 State], s.[Box 32 Zip], s.[Box 33 Payee Provider #], s.[Box 33 Payee Provider Last], s.[Box 33 Payee Provider First], s.[Box 33 Payee Provider NPI], s.[Box 33 Payee Provider Address Type], s.[Box 33 Payee Provider Street], s.[Box 33 Payee Provider Street 2], s.[Box 33 Payee Provider City], s.[Box 33 Payee Provider State], s.[Box 33 Payee Provider Zip], s.[PCP Provider #], s.[PCP Last], s.[PCP First], s.[SequenceNumber], s.[LineItemControlNumber], s.[Claimtype], s.[DischargeStatus], s.[AdmissionDate], s.[DischargeDate], s.[AdmissionSourceCode], s.[Payor]);
 
 
 --SET IDENTITY_INSERT [dbo].[CCAIClaimDetailExtract] OFF;
 

--SET IDENTITY_INSERT [dbo].[CCAIClaimICDExtract] ON;
    
--MERGE [dbo].[CCAIClaimICDExtract] AS t
--USING (SELECT * FROM [CCAI_Claims_Export_Update].[dbo].[CCAIClaimICDExtract] WITH(NOLOCK)) as s
--ON ( t.[ICD Sequence Number] = s.[ICD Sequence Number] )
--WHEN MATCHED THEN UPDATE SET
--    [Claim_number] = s.[Claim_number],
--    [Claim_ICD_number] = s.[Claim_ICD_number],
--    [ICD Type] = s.[ICD Type],
--    [ICD Line Number] = s.[ICD Line Number],
--    [HI_Position] = s.[HI_Position],
--    [PresentOnAdmission] = s.[PresentOnAdmission]
-- WHEN NOT MATCHED BY TARGET THEN
--    INSERT([Claim_number], [Claim_ICD_number], [ICD Type], [ICD Line Number], [HI_Position], [ICD Sequence Number], [PresentOnAdmission])
--    VALUES(s.[Claim_number], s.[Claim_ICD_number], s.[ICD Type], s.[ICD Line Number], s.[HI_Position], s.[ICD Sequence Number], s.[PresentOnAdmission]);

--SET IDENTITY_INSERT [dbo].[CCAIClaimICDExtract] OFF;
    

END
GO
