SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jason Franks
-- Create date: 1/14/2016
-- Description:	Data Vault Claim Load
-- Example: [dbo].[prDV_Claim_LoadSats]
-- =============================================
CREATE PROCEDURE [dbo].[prDV_Claim_LoadSats]
	-- Add the parameters for the stored procedure here
	AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

--**S_ClaimsDetail LOAD

INSERT INTO [dbo].[S_ClaimDetail]
           ([S_ClaimDetail_RK]
           ,[LoadDate]
           ,[H_Claim_RK]
           ,[ClaimStatus]
           ,[POS]
           ,[TOS]
           ,[TOB]
           ,[HRC]
           ,[FromDate]
           ,[ToDate]
           ,[CPT]
           ,[Modifier1]
           ,[Modifier2]
           ,[Modifier3]
           ,[Modifier4]
           ,[Units]
           ,[AmountBilled]
           ,[AllowedCharge]
           ,[Copay]
           ,[Coinsurance]
           ,[TotalAllowed]
           ,[AmountPaid]
           ,[DOR]
           ,[DOP]
           ,[AdjudicationCode]
           ,[AdjudicationCodeDesc]
           ,[AuthorizationNumber]
           ,[ReferralNumber]
           ,[CheckNumber]
           ,[RenderingProviderNum]
           ,[RenderingProviderCPI]
           ,[RenderingProviderLName]
           ,[RenderingProviderFName]
           ,[RenderingProviderNetworkStatus]
           ,[RenderingProviderFacilityStatus]
           ,[RenderingProviderNPI]
           ,[RenderingProviderSpecialtyCode]
           ,[RenderingProviderSpecialty]
           ,[RenderingProviderLocation_RK]
           ,[TaxID]
           ,[PayeeProviderNum]
           ,[PayeeProviderCPI]
           ,[PayeeProviderLName]
           ,[PayeeProviderFName]
           ,[PayeeProviderNPI]
           ,[PayeeProviderLocation_RK]
           ,[PayeeProviderAddressType]
           ,[PayeeProviderAddress1]
           ,[PayeeProviderAddress2]
           ,[PayeeProviderCity]
           ,[PayeeProviderState]
           ,[PayeeProviderZip]
           ,[PCPProviderNum]
           ,[PCPLName]
           ,[PCPFName]
           ,[SequenceNumber]
           ,[LineItemControlNumber]
           ,[ClaimType]
           ,[DischargeStatus]
           ,[AdmissionDate]
           ,[DischargeDate]
           ,[AdmissionSourceCode]
           ,[Payor]
           ,[HashDiff]
           ,[RecordEndDate]
		   ,[RecordSource])
          Select 
		  upper(convert(char(32), HashBytes('MD5',
			Upper(Concat(
				RTRIM(LTRIM(COALESCE([Claim Number],''))),':',
				RTRIM(LTRIM(COALESCE([Member ID#],''))),':',
				RTRIM(LTRIM(COALESCE([CCI],''))),':',
				RTRIM(LTRIM(COALESCE([Claim Status],''))),':',
					RTRIM(LTRIM(COALESCE([POS],''))),':',
					RTRIM(LTRIM(COALESCE([TOS],''))),':',
					RTRIM(LTRIM(COALESCE([TOB],''))),':',
					RTRIM(LTRIM(COALESCE([HRC],''))),':',
					RTRIM(LTRIM(COALESCE([From Date],''))),':',
					RTRIM(LTRIM(COALESCE([To Date],''))),':',
					RTRIM(LTRIM(COALESCE([CPT],''))),':',
					RTRIM(LTRIM(COALESCE([Modifier1],''))),':',
					RTRIM(LTRIM(COALESCE([Modifier2],''))),':',
					RTRIM(LTRIM(COALESCE([Modifier3],''))),':',
					RTRIM(LTRIM(COALESCE([Modifier4],''))),':',
					RTRIM(LTRIM(COALESCE([Units],''))),':',
					RTRIM(LTRIM(COALESCE([Amount Billed],''))),':',
					RTRIM(LTRIM(COALESCE([Allowed Charge],''))),':',
					RTRIM(LTRIM(COALESCE([Copay],''))),':',
					RTRIM(LTRIM(COALESCE([Coinsurance],''))),':',
					RTRIM(LTRIM(COALESCE([Total Allowed],''))),':',
					RTRIM(LTRIM(COALESCE([Amount Paid],''))),':',
					RTRIM(LTRIM(COALESCE([DOR],''))),':',
					RTRIM(LTRIM(COALESCE([DOP],''))),':',
					RTRIM(LTRIM(COALESCE([Adjudication Code],''))),':',
					RTRIM(LTRIM(COALESCE([Adjudication Code Description],''))),':',
					RTRIM(LTRIM(COALESCE([Authorization Number],''))),':',
					RTRIM(LTRIM(COALESCE([Referral Number],''))),':',
					RTRIM(LTRIM(COALESCE([Rendering Provider #],''))),':',
					RTRIM(LTRIM(COALESCE(CPI,''))),':',
					RTRIM(LTRIM(COALESCE([Rendering Provider Last],''))),':',
					RTRIM(LTRIM(COALESCE([Rendering Provider First],''))),':',
					RTRIM(LTRIM(COALESCE([Rendering Provider Network Status],''))),':',
					RTRIM(LTRIM(COALESCE([Rendering Provider Facility Status],''))),':',
					RTRIM(LTRIM(COALESCE([Rendering Provider NPI],''))),':',
					RTRIM(LTRIM(COALESCE([Rendering Provider Specialty Code],''))),':',
					RTRIM(LTRIM(COALESCE([Rendering Provider Specialty],''))),':',
					RTRIM(LTRIM(COALESCE(null,''))),':',--RenderingProviderLocation_RK
					RTRIM(LTRIM(COALESCE([Tax ID#],''))),':',
					RTRIM(LTRIM(COALESCE([Box 33 Payee Provider #],''))),':',
					RTRIM(LTRIM(COALESCE(NULL,''))),':',--[PayeeProviderCPI]
					RTRIM(LTRIM(COALESCE([Box 33 Payee Provider Last],''))),':',
					RTRIM(LTRIM(COALESCE([Box 33 Payee Provider First],''))),':',
					RTRIM(LTRIM(COALESCE([Box 33 Payee Provider NPI],''))),':',
					RTRIM(LTRIM(COALESCE(NULL,''))),':',--PayeeProviderLocation_RK
					RTRIM(LTRIM(COALESCE([Box 33 Payee Provider Address Type],''))),':',
					RTRIM(LTRIM(COALESCE([Box 33 Payee Provider Street],''))),':',
					RTRIM(LTRIM(COALESCE([Box 33 Payee Provider Street 2],''))),':',
					RTRIM(LTRIM(COALESCE([Box 33 Payee Provider City],''))),':',
					RTRIM(LTRIM(COALESCE([Box 33 Payee Provider State],''))),':',
					RTRIM(LTRIM(COALESCE([Box 33 Payee Provider Zip],''))),':',
					RTRIM(LTRIM(COALESCE([PCP Provider #],''))),':',
					RTRIM(LTRIM(COALESCE([PCP Last],''))),':',
					RTRIM(LTRIM(COALESCE([PCP First],''))),':',
					RTRIM(LTRIM(COALESCE([SequenceNumber],''))),':',
					RTRIM(LTRIM(COALESCE([LineItemControlNumber],''))),':',
					RTRIM(LTRIM(COALESCE([ClaimType],''))),':',
					RTRIM(LTRIM(COALESCE([DischargeStatus],''))),':',
					RTRIM(LTRIM(COALESCE([AdmissionDate],''))),':',
					RTRIM(LTRIM(COALESCE([DischargeDate],''))),':',
					RTRIM(LTRIM(COALESCE([AdmissionSourceCode],''))),':',
					RTRIM(LTRIM(COALESCE([Payor],'')))
			))
			),2)),
			LoadDate,
			upper(convert(char(32), HashBytes('MD5',
			Upper(Concat(
				RTRIM(LTRIM(COALESCE([Claim Number],''))),':',
				RTRIM(LTRIM(COALESCE([Member ID#],''))),':',
				RTRIM(LTRIM(COALESCE(CCI,''))))
			)),2)),
			[Claim Status]
           ,[POS]
           ,[TOS]
           ,[TOB]
           ,[HRC]
           ,[From Date]
           ,[To Date]
           ,[CPT]
           ,[Modifier1]
           ,[Modifier2]
           ,[Modifier3]
           ,[Modifier4]
           ,[Units]
           ,[Amount Billed]
           ,[Allowed Charge]
           ,[Copay]
           ,[Coinsurance]
           ,[Total Allowed]
           ,[Amount Paid]
           ,[DOR]
           ,[DOP]
           ,[Adjudication Code]
           ,[Adjudication Code Description]
           ,[Authorization Number]
           ,[Referral Number]
           ,[Check Number]
           ,[Rendering Provider #]
           ,CPI
           ,[Rendering Provider Last]
		   ,[Rendering Provider First]
           ,[Rendering Provider Network Status]
           ,[Rendering Provider Facility Status]
           ,[Rendering Provider NPI]
           ,[Rendering Provider Specialty Code]
           ,[Rendering Provider Specialty]
           ,''--[RenderingProviderLocation_RK]
           ,[Tax ID#]
           ,[Box 33 Payee Provider #]
           ,''--[PayeeProviderCMI]
           ,[Box 33 Payee Provider Last]
           ,[Box 33 Payee Provider First]
           ,[Box 33 Payee Provider NPI]
           ,''--[PayeeProviderLocation_RK]
           ,[Box 33 Payee Provider Address Type]
           ,[Box 33 Payee Provider Street]
           ,[Box 33 Payee Provider Street 2]
           ,[Box 33 Payee Provider City]
           ,[Box 33 Payee Provider State]
		   ,[Box 33 Payee Provider Zip]
           ,[PCP Provider #]
           ,[PCP Last]
           ,[PCP First]
           ,[SequenceNumber]
           ,[LineItemControlNumber]
           ,[ClaimType]
           ,[DischargeStatus]
           ,[AdmissionDate]
           ,[DischargeDate]
           ,[AdmissionSourceCode]
           ,[Payor]
		   ,  upper(convert(char(32), HashBytes('MD5',
			Upper(Concat(
					RTRIM(LTRIM(COALESCE([Claim Status],''))),':',
					RTRIM(LTRIM(COALESCE([POS],''))),':',
					RTRIM(LTRIM(COALESCE([TOS],''))),':',
					RTRIM(LTRIM(COALESCE([TOB],''))),':',
					RTRIM(LTRIM(COALESCE([HRC],''))),':',
					RTRIM(LTRIM(COALESCE([From Date],''))),':',
					RTRIM(LTRIM(COALESCE([To Date],''))),':',
					RTRIM(LTRIM(COALESCE([CPT],''))),':',
					RTRIM(LTRIM(COALESCE([Modifier1],''))),':',
					RTRIM(LTRIM(COALESCE([Modifier2],''))),':',
					RTRIM(LTRIM(COALESCE([Modifier3],''))),':',
					RTRIM(LTRIM(COALESCE([Modifier4],''))),':',
					RTRIM(LTRIM(COALESCE([Units],''))),':',
					RTRIM(LTRIM(COALESCE([Amount Billed],''))),':',
					RTRIM(LTRIM(COALESCE([Allowed Charge],''))),':',
					RTRIM(LTRIM(COALESCE([Copay],''))),':',
					RTRIM(LTRIM(COALESCE([Coinsurance],''))),':',
					RTRIM(LTRIM(COALESCE([Total Allowed],''))),':',
					RTRIM(LTRIM(COALESCE([Amount Paid],''))),':',
					RTRIM(LTRIM(COALESCE([DOR],''))),':',
					RTRIM(LTRIM(COALESCE([DOP],''))),':',
					RTRIM(LTRIM(COALESCE([Adjudication Code],''))),':',
					RTRIM(LTRIM(COALESCE([Adjudication Code Description],''))),':',
					RTRIM(LTRIM(COALESCE([Authorization Number],''))),':',
					RTRIM(LTRIM(COALESCE([Referral Number],''))),':',
					RTRIM(LTRIM(COALESCE([Rendering Provider #],''))),':',
					RTRIM(LTRIM(COALESCE(CPI,''))),':',
					RTRIM(LTRIM(COALESCE([Rendering Provider Last],''))),':',
					RTRIM(LTRIM(COALESCE([Rendering Provider First],''))),':',
					RTRIM(LTRIM(COALESCE([Rendering Provider Network Status],''))),':',
					RTRIM(LTRIM(COALESCE([Rendering Provider Facility Status],''))),':',
					RTRIM(LTRIM(COALESCE([Rendering Provider NPI],''))),':',
					RTRIM(LTRIM(COALESCE([Rendering Provider Specialty Code],''))),':',
					RTRIM(LTRIM(COALESCE([Rendering Provider Specialty],''))),':',
					RTRIM(LTRIM(COALESCE(null,''))),':',--RenderingProviderLocation_RK
					RTRIM(LTRIM(COALESCE([Tax ID#],''))),':',
					RTRIM(LTRIM(COALESCE([Box 33 Payee Provider #],''))),':',
					RTRIM(LTRIM(COALESCE(NULL,''))),':',--[PayeeProviderCPI]
					RTRIM(LTRIM(COALESCE([Box 33 Payee Provider Last],''))),':',
					RTRIM(LTRIM(COALESCE([Box 33 Payee Provider First],''))),':',
					RTRIM(LTRIM(COALESCE([Box 33 Payee Provider NPI],''))),':',
					RTRIM(LTRIM(COALESCE(NULL,''))),':',--PayeeProviderLocation_RK
					RTRIM(LTRIM(COALESCE([Box 33 Payee Provider Address Type],''))),':',
					RTRIM(LTRIM(COALESCE([Box 33 Payee Provider Street],''))),':',
					RTRIM(LTRIM(COALESCE([Box 33 Payee Provider Street 2],''))),':',
					RTRIM(LTRIM(COALESCE([Box 33 Payee Provider City],''))),':',
					RTRIM(LTRIM(COALESCE([Box 33 Payee Provider State],''))),':',
					RTRIM(LTRIM(COALESCE([Box 33 Payee Provider Zip],''))),':',
					RTRIM(LTRIM(COALESCE([PCP Provider #],''))),':',
					RTRIM(LTRIM(COALESCE([PCP Last],''))),':',
					RTRIM(LTRIM(COALESCE([PCP First],''))),':',
					RTRIM(LTRIM(COALESCE([SequenceNumber],''))),':',
					RTRIM(LTRIM(COALESCE([LineItemControlNumber],''))),':',
					RTRIM(LTRIM(COALESCE([ClaimType],''))),':',
					RTRIM(LTRIM(COALESCE([DischargeStatus],''))),':',
					RTRIM(LTRIM(COALESCE([AdmissionDate],''))),':',
					RTRIM(LTRIM(COALESCE([DischargeDate],''))),':',
					RTRIM(LTRIM(COALESCE([AdmissionSourceCode],''))),':',
					RTRIM(LTRIM(COALESCE([Payor],'')))
			))
			),2))
		   ,null
		   ,RecordSource
		  from CHSStaging.dbo.Claims_Stage_Raw with(nolock)
		  where 
		    upper(convert(char(32), HashBytes('MD5',
			Upper(Concat(
					RTRIM(LTRIM(COALESCE([Claim Status],''))),':',
					RTRIM(LTRIM(COALESCE([POS],''))),':',
					RTRIM(LTRIM(COALESCE([TOS],''))),':',
					RTRIM(LTRIM(COALESCE([TOB],''))),':',
					RTRIM(LTRIM(COALESCE([HRC],''))),':',
					RTRIM(LTRIM(COALESCE([From Date],''))),':',
					RTRIM(LTRIM(COALESCE([To Date],''))),':',
					RTRIM(LTRIM(COALESCE([CPT],''))),':',
					RTRIM(LTRIM(COALESCE([Modifier1],''))),':',
					RTRIM(LTRIM(COALESCE([Modifier2],''))),':',
					RTRIM(LTRIM(COALESCE([Modifier3],''))),':',
					RTRIM(LTRIM(COALESCE([Modifier4],''))),':',
					RTRIM(LTRIM(COALESCE([Units],''))),':',
					RTRIM(LTRIM(COALESCE([Amount Billed],''))),':',
					RTRIM(LTRIM(COALESCE([Allowed Charge],''))),':',
					RTRIM(LTRIM(COALESCE([Copay],''))),':',
					RTRIM(LTRIM(COALESCE([Coinsurance],''))),':',
					RTRIM(LTRIM(COALESCE([Total Allowed],''))),':',
					RTRIM(LTRIM(COALESCE([Amount Paid],''))),':',
					RTRIM(LTRIM(COALESCE([DOR],''))),':',
					RTRIM(LTRIM(COALESCE([DOP],''))),':',
					RTRIM(LTRIM(COALESCE([Adjudication Code],''))),':',
					RTRIM(LTRIM(COALESCE([Adjudication Code Description],''))),':',
					RTRIM(LTRIM(COALESCE([Authorization Number],''))),':',
					RTRIM(LTRIM(COALESCE([Referral Number],''))),':',
					RTRIM(LTRIM(COALESCE([Rendering Provider #],''))),':',
					RTRIM(LTRIM(COALESCE(CPI,''))),':',
					RTRIM(LTRIM(COALESCE([Rendering Provider Last],''))),':',
					RTRIM(LTRIM(COALESCE([Rendering Provider First],''))),':',
					RTRIM(LTRIM(COALESCE([Rendering Provider Network Status],''))),':',
					RTRIM(LTRIM(COALESCE([Rendering Provider Facility Status],''))),':',
					RTRIM(LTRIM(COALESCE([Rendering Provider NPI],''))),':',
					RTRIM(LTRIM(COALESCE([Rendering Provider Specialty Code],''))),':',
					RTRIM(LTRIM(COALESCE([Rendering Provider Specialty],''))),':',
					RTRIM(LTRIM(COALESCE(null,''))),':',--RenderingProviderLocation_RK
					RTRIM(LTRIM(COALESCE([Tax ID#],''))),':',
					RTRIM(LTRIM(COALESCE([Box 33 Payee Provider #],''))),':',
					RTRIM(LTRIM(COALESCE(NULL,''))),':',--[PayeeProviderCPI]
					RTRIM(LTRIM(COALESCE([Box 33 Payee Provider Last],''))),':',
					RTRIM(LTRIM(COALESCE([Box 33 Payee Provider First],''))),':',
					RTRIM(LTRIM(COALESCE([Box 33 Payee Provider NPI],''))),':',
					RTRIM(LTRIM(COALESCE(NULL,''))),':',--PayeeProviderLocation_RK
					RTRIM(LTRIM(COALESCE([Box 33 Payee Provider Address Type],''))),':',
					RTRIM(LTRIM(COALESCE([Box 33 Payee Provider Street],''))),':',
					RTRIM(LTRIM(COALESCE([Box 33 Payee Provider Street 2],''))),':',
					RTRIM(LTRIM(COALESCE([Box 33 Payee Provider City],''))),':',
					RTRIM(LTRIM(COALESCE([Box 33 Payee Provider State],''))),':',
					RTRIM(LTRIM(COALESCE([Box 33 Payee Provider Zip],''))),':',
					RTRIM(LTRIM(COALESCE([PCP Provider #],''))),':',
					RTRIM(LTRIM(COALESCE([PCP Last],''))),':',
					RTRIM(LTRIM(COALESCE([PCP First],''))),':',
					RTRIM(LTRIM(COALESCE([SequenceNumber],''))),':',
					RTRIM(LTRIM(COALESCE([LineItemControlNumber],''))),':',
					RTRIM(LTRIM(COALESCE([ClaimType],''))),':',
					RTRIM(LTRIM(COALESCE([DischargeStatus],''))),':',
					RTRIM(LTRIM(COALESCE([AdmissionDate],''))),':',
					RTRIM(LTRIM(COALESCE([DischargeDate],''))),':',
					RTRIM(LTRIM(COALESCE([AdmissionSourceCode],''))),':',
					RTRIM(LTRIM(COALESCE([Payor],'')))
			))
			),2)) not in (Select HashDiff from S_ClaimDetail where RecordEndDate is null)
		  group by
		    upper(convert(char(32), HashBytes('MD5',
			Upper(Concat(
				RTRIM(LTRIM(COALESCE([Claim Number],''))),':',
				RTRIM(LTRIM(COALESCE([Member ID#],''))),':',
				RTRIM(LTRIM(COALESCE([CCI],''))),':',
				RTRIM(LTRIM(COALESCE([Claim Status],''))),':',
					RTRIM(LTRIM(COALESCE([POS],''))),':',
					RTRIM(LTRIM(COALESCE([TOS],''))),':',
					RTRIM(LTRIM(COALESCE([TOB],''))),':',
					RTRIM(LTRIM(COALESCE([HRC],''))),':',
					RTRIM(LTRIM(COALESCE([From Date],''))),':',
					RTRIM(LTRIM(COALESCE([To Date],''))),':',
					RTRIM(LTRIM(COALESCE([CPT],''))),':',
					RTRIM(LTRIM(COALESCE([Modifier1],''))),':',
					RTRIM(LTRIM(COALESCE([Modifier2],''))),':',
					RTRIM(LTRIM(COALESCE([Modifier3],''))),':',
					RTRIM(LTRIM(COALESCE([Modifier4],''))),':',
					RTRIM(LTRIM(COALESCE([Units],''))),':',
					RTRIM(LTRIM(COALESCE([Amount Billed],''))),':',
					RTRIM(LTRIM(COALESCE([Allowed Charge],''))),':',
					RTRIM(LTRIM(COALESCE([Copay],''))),':',
					RTRIM(LTRIM(COALESCE([Coinsurance],''))),':',
					RTRIM(LTRIM(COALESCE([Total Allowed],''))),':',
					RTRIM(LTRIM(COALESCE([Amount Paid],''))),':',
					RTRIM(LTRIM(COALESCE([DOR],''))),':',
					RTRIM(LTRIM(COALESCE([DOP],''))),':',
					RTRIM(LTRIM(COALESCE([Adjudication Code],''))),':',
					RTRIM(LTRIM(COALESCE([Adjudication Code Description],''))),':',
					RTRIM(LTRIM(COALESCE([Authorization Number],''))),':',
					RTRIM(LTRIM(COALESCE([Referral Number],''))),':',
					RTRIM(LTRIM(COALESCE([Rendering Provider #],''))),':',
					RTRIM(LTRIM(COALESCE(CPI,''))),':',
					RTRIM(LTRIM(COALESCE([Rendering Provider Last],''))),':',
					RTRIM(LTRIM(COALESCE([Rendering Provider First],''))),':',
					RTRIM(LTRIM(COALESCE([Rendering Provider Network Status],''))),':',
					RTRIM(LTRIM(COALESCE([Rendering Provider Facility Status],''))),':',
					RTRIM(LTRIM(COALESCE([Rendering Provider NPI],''))),':',
					RTRIM(LTRIM(COALESCE([Rendering Provider Specialty Code],''))),':',
					RTRIM(LTRIM(COALESCE([Rendering Provider Specialty],''))),':',
					RTRIM(LTRIM(COALESCE(null,''))),':',--RenderingProviderLocation_RK
					RTRIM(LTRIM(COALESCE([Tax ID#],''))),':',
					RTRIM(LTRIM(COALESCE([Box 33 Payee Provider #],''))),':',
					RTRIM(LTRIM(COALESCE(NULL,''))),':',--[PayeeProviderCPI]
					RTRIM(LTRIM(COALESCE([Box 33 Payee Provider Last],''))),':',
					RTRIM(LTRIM(COALESCE([Box 33 Payee Provider First],''))),':',
					RTRIM(LTRIM(COALESCE([Box 33 Payee Provider NPI],''))),':',
					RTRIM(LTRIM(COALESCE(NULL,''))),':',--PayeeProviderLocation_RK
					RTRIM(LTRIM(COALESCE([Box 33 Payee Provider Address Type],''))),':',
					RTRIM(LTRIM(COALESCE([Box 33 Payee Provider Street],''))),':',
					RTRIM(LTRIM(COALESCE([Box 33 Payee Provider Street 2],''))),':',
					RTRIM(LTRIM(COALESCE([Box 33 Payee Provider City],''))),':',
					RTRIM(LTRIM(COALESCE([Box 33 Payee Provider State],''))),':',
					RTRIM(LTRIM(COALESCE([Box 33 Payee Provider Zip],''))),':',
					RTRIM(LTRIM(COALESCE([PCP Provider #],''))),':',
					RTRIM(LTRIM(COALESCE([PCP Last],''))),':',
					RTRIM(LTRIM(COALESCE([PCP First],''))),':',
					RTRIM(LTRIM(COALESCE([SequenceNumber],''))),':',
					RTRIM(LTRIM(COALESCE([LineItemControlNumber],''))),':',
					RTRIM(LTRIM(COALESCE([ClaimType],''))),':',
					RTRIM(LTRIM(COALESCE([DischargeStatus],''))),':',
					RTRIM(LTRIM(COALESCE([AdmissionDate],''))),':',
					RTRIM(LTRIM(COALESCE([DischargeDate],''))),':',
					RTRIM(LTRIM(COALESCE([AdmissionSourceCode],''))),':',
					RTRIM(LTRIM(COALESCE([Payor],'')))
			))
			),2)),
			LoadDate,
			upper(convert(char(32), HashBytes('MD5',
			Upper(Concat(
				RTRIM(LTRIM(COALESCE([Claim Number],''))),':',
				RTRIM(LTRIM(COALESCE([Member ID#],''))),':',
				RTRIM(LTRIM(COALESCE(CCI,''))))
			)),2)),
			[Claim Status]
           ,[POS]
           ,[TOS]
           ,[TOB]
           ,[HRC]
           ,[From Date]
           ,[To Date]
           ,[CPT]
           ,[Modifier1]
           ,[Modifier2]
           ,[Modifier3]
           ,[Modifier4]
           ,[Units]
           ,[Amount Billed]
           ,[Allowed Charge]
           ,[Copay]
           ,[Coinsurance]
           ,[Total Allowed]
           ,[Amount Paid]
           ,[DOR]
           ,[DOP]
           ,[Adjudication Code]
           ,[Adjudication Code Description]
           ,[Authorization Number]
           ,[Referral Number]
           ,[Check Number]
           ,[Rendering Provider #]
           ,CPI
           ,[Rendering Provider Last]
		   ,[Rendering Provider First]
           ,[Rendering Provider Network Status]
           ,[Rendering Provider Facility Status]
           ,[Rendering Provider NPI]
           ,[Rendering Provider Specialty Code]
           ,[Rendering Provider Specialty]
           --[RenderingProviderLocation_RK]
           ,[Tax ID#]
           ,[Box 33 Payee Provider #]
           --[PayeeProviderCMI]
           ,[Box 33 Payee Provider Last]
           ,[Box 33 Payee Provider First]
           ,[Box 33 Payee Provider NPI]
           --[PayeeProviderLocation_RK]
           ,[Box 33 Payee Provider Address Type]
           ,[Box 33 Payee Provider Street]
           ,[Box 33 Payee Provider Street 2]
           ,[Box 33 Payee Provider City]
           ,[Box 33 Payee Provider State]
		   ,[Box 33 Payee Provider Zip]
           ,[PCP Provider #]
           ,[PCP Last]
           ,[PCP First]
           ,[SequenceNumber]
           ,[LineItemControlNumber]
           ,[ClaimType]
           ,[DischargeStatus]
           ,[AdmissionDate]
           ,[DischargeDate]
           ,[AdmissionSourceCode]
           ,[Payor]
		   ,  upper(convert(char(32), HashBytes('MD5',
			Upper(Concat(
					RTRIM(LTRIM(COALESCE([Claim Status],''))),':',
					RTRIM(LTRIM(COALESCE([POS],''))),':',
					RTRIM(LTRIM(COALESCE([TOS],''))),':',
					RTRIM(LTRIM(COALESCE([TOB],''))),':',
					RTRIM(LTRIM(COALESCE([HRC],''))),':',
					RTRIM(LTRIM(COALESCE([From Date],''))),':',
					RTRIM(LTRIM(COALESCE([To Date],''))),':',
					RTRIM(LTRIM(COALESCE([CPT],''))),':',
					RTRIM(LTRIM(COALESCE([Modifier1],''))),':',
					RTRIM(LTRIM(COALESCE([Modifier2],''))),':',
					RTRIM(LTRIM(COALESCE([Modifier3],''))),':',
					RTRIM(LTRIM(COALESCE([Modifier4],''))),':',
					RTRIM(LTRIM(COALESCE([Units],''))),':',
					RTRIM(LTRIM(COALESCE([Amount Billed],''))),':',
					RTRIM(LTRIM(COALESCE([Allowed Charge],''))),':',
					RTRIM(LTRIM(COALESCE([Copay],''))),':',
					RTRIM(LTRIM(COALESCE([Coinsurance],''))),':',
					RTRIM(LTRIM(COALESCE([Total Allowed],''))),':',
					RTRIM(LTRIM(COALESCE([Amount Paid],''))),':',
					RTRIM(LTRIM(COALESCE([DOR],''))),':',
					RTRIM(LTRIM(COALESCE([DOP],''))),':',
					RTRIM(LTRIM(COALESCE([Adjudication Code],''))),':',
					RTRIM(LTRIM(COALESCE([Adjudication Code Description],''))),':',
					RTRIM(LTRIM(COALESCE([Authorization Number],''))),':',
					RTRIM(LTRIM(COALESCE([Referral Number],''))),':',
					RTRIM(LTRIM(COALESCE([Rendering Provider #],''))),':',
					RTRIM(LTRIM(COALESCE(CPI,''))),':',
					RTRIM(LTRIM(COALESCE([Rendering Provider Last],''))),':',
					RTRIM(LTRIM(COALESCE([Rendering Provider First],''))),':',
					RTRIM(LTRIM(COALESCE([Rendering Provider Network Status],''))),':',
					RTRIM(LTRIM(COALESCE([Rendering Provider Facility Status],''))),':',
					RTRIM(LTRIM(COALESCE([Rendering Provider NPI],''))),':',
					RTRIM(LTRIM(COALESCE([Rendering Provider Specialty Code],''))),':',
					RTRIM(LTRIM(COALESCE([Rendering Provider Specialty],''))),':',
					RTRIM(LTRIM(COALESCE(null,''))),':',--RenderingProviderLocation_RK
					RTRIM(LTRIM(COALESCE([Tax ID#],''))),':',
					RTRIM(LTRIM(COALESCE([Box 33 Payee Provider #],''))),':',
					RTRIM(LTRIM(COALESCE(NULL,''))),':',--[PayeeProviderCPI]
					RTRIM(LTRIM(COALESCE([Box 33 Payee Provider Last],''))),':',
					RTRIM(LTRIM(COALESCE([Box 33 Payee Provider First],''))),':',
					RTRIM(LTRIM(COALESCE([Box 33 Payee Provider NPI],''))),':',
					RTRIM(LTRIM(COALESCE(NULL,''))),':',--PayeeProviderLocation_RK
					RTRIM(LTRIM(COALESCE([Box 33 Payee Provider Address Type],''))),':',
					RTRIM(LTRIM(COALESCE([Box 33 Payee Provider Street],''))),':',
					RTRIM(LTRIM(COALESCE([Box 33 Payee Provider Street 2],''))),':',
					RTRIM(LTRIM(COALESCE([Box 33 Payee Provider City],''))),':',
					RTRIM(LTRIM(COALESCE([Box 33 Payee Provider State],''))),':',
					RTRIM(LTRIM(COALESCE([Box 33 Payee Provider Zip],''))),':',
					RTRIM(LTRIM(COALESCE([PCP Provider #],''))),':',
					RTRIM(LTRIM(COALESCE([PCP Last],''))),':',
					RTRIM(LTRIM(COALESCE([PCP First],''))),':',
					RTRIM(LTRIM(COALESCE([SequenceNumber],''))),':',
					RTRIM(LTRIM(COALESCE([LineItemControlNumber],''))),':',
					RTRIM(LTRIM(COALESCE([ClaimType],''))),':',
					RTRIM(LTRIM(COALESCE([DischargeStatus],''))),':',
					RTRIM(LTRIM(COALESCE([AdmissionDate],''))),':',
					RTRIM(LTRIM(COALESCE([DischargeDate],''))),':',
					RTRIM(LTRIM(COALESCE([AdmissionSourceCode],''))),':',
					RTRIM(LTRIM(COALESCE([Payor],'')))
			))
			),2))
		   ,RecordSource

		   ALTER INDEX IDX_HashDiff ON dbo.S_ClaimDetail
		   REBUILD;
		   ALTER INDEX [IDX_RecordEndDate] ON dbo.S_ClaimDetail
		   REBUILD;
		   ALTER INDEX [PK_S_ClaimDetail] ON dbo.S_ClaimDetail
		   REBUILD;
END
GO
