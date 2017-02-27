SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- ============================================= 
-- Author:		Travis Parker 
-- Create date:	02/23/2017 
-- Description:	Load the Satellite tables for the TRR staging table 
-- ============================================= 
CREATE PROCEDURE [dbo].[spDV_TRR_LoadSats] 
	-- Add the parameters for the stored procedure here 
AS 
    BEGIN 
 
        DECLARE @CurrentDate DATETIME = GETDATE(); 
 
        SET NOCOUNT ON; 
 
	   --LOAD MemberHICN RECORDS for TRR 
        INSERT  INTO dbo.S_MemberHICN 
                ( S_MemberHICN_RK , 
                  LoadDate , 
                  H_Member_RK , 
                  HICNumber , 
                  HashDiff , 
                  RecordSource  
	           ) 
                SELECT DISTINCT 
                        m.S_MemberHICN_RK , 
                        @CurrentDate , 
                        m.H_Member_RK , 
                        m.HICN , 
                        m.S_MemberHICN_HashDiff , 
                        m.FileName 
                FROM    CHSStaging.dbo.TRRStaging m 
                        LEFT JOIN dbo.S_MemberHICN s ON s.H_Member_RK = m.H_Member_RK 
                                                        AND s.RecordEndDate IS NULL 
                                                        AND s.HashDiff = m.S_MemberHICN_HashDiff 
                WHERE   s.S_MemberHICN_RK IS NULL 
                        AND m.H_Member_RK IS NOT NULL; 
 
 
	   --RECORD END DATE CLEANUP 
        UPDATE  dbo.S_MemberHICN 
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate)) 
                                  FROM      dbo.S_MemberHICN AS z 
                                  WHERE     z.H_Member_RK = a.H_Member_RK 
                                            AND z.LoadDate > a.LoadDate 
                                ) 
        FROM    dbo.S_MemberHICN a 
        WHERE   a.RecordEndDate IS NULL; 
 
	   --LOAD MemberHICN RECORDS for VERBATIM 
        INSERT  INTO dbo.S_MemberHICN 
                ( S_MemberHICN_RK , 
                  LoadDate , 
                  H_Member_RK , 
                  HICNumber , 
                  HashDiff , 
                  RecordSource  
	           ) 
                SELECT DISTINCT 
                        m.S_MemberHICN_RK , 
                        @CurrentDate , 
                        m.H_Member_RK , 
                        m.HICN , 
                        m.S_MemberHICN_HashDiff , 
                        m.FileName 
                FROM    CHSStaging.dbo.TRRVerbatimStaging m 
                        LEFT JOIN dbo.S_MemberHICN s ON s.H_Member_RK = m.H_Member_RK 
                                                        AND s.RecordEndDate IS NULL 
                                                        AND s.HashDiff = m.S_MemberHICN_HashDiff 
                WHERE   s.S_MemberHICN_RK IS NULL 
                        AND m.H_Member_RK IS NOT NULL; 
 
 
	   --RECORD END DATE CLEANUP 
        UPDATE  dbo.S_MemberHICN 
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate)) 
                                  FROM      dbo.S_MemberHICN AS z 
                                  WHERE     z.H_Member_RK = a.H_Member_RK 
                                            AND z.LoadDate > a.LoadDate 
                                ) 
        FROM    dbo.S_MemberHICN a 
        WHERE   a.RecordEndDate IS NULL; 
	    
	    
	   --LOAD TRR Detail 
        INSERT  INTO dbo.S_TRR 
                ( S_TRR_RK , 
                  H_TRR_RK , 
                  HICN , 
                  Surname , 
                  FirstName , 
                  MiddleInitial , 
                  GenderCode , 
                  DOB , 
                  RecordType , 
                  ContractNumber , 
                  StateCode , 
                  CountyCode , 
                  DisabilityIndicator , 
                  HospiceIndicator , 
                  Institutional_NHC_HC_BS_Indicator , 
                  ESRDIndicator , 
                  TransactionReplyCode , 
                  TransactionTypeCode , 
                  EntitlementTypeCode , 
                  EffectiveDate , 
                  WAIndicator , 
                  PlanBenefitPackageID , 
                  TransactionDate , 
                  UIInitiatedChangeFlag , 
                  TRCValue , 
                  DistrictOfficeCode , 
                  PrevPartD_Contract_PBP_ForTroopTransfer , 
                  SourceID , 
                  PriorPlanBenefitPackageID , 
                  ApplicationDate , 
                  UIUserOrganizationDesignation , 
                  OutOfAreaFlag , 
                  SegmentNumber , 
                  PartC_BeneficiaryPremium , 
                  PartD_BeneficiaryPremium , 
                  ElectionType , 
                  EnrollmentSource , 
                  PartD_OptOutFlag , 
                  PremiumWithholdOption_PartsC_D , 
                  CumulativeNumberOfUncoveredMonths , 
                  CreditableCoverageFlag , 
                  EmployerSubsidyOverrideFlag , 
                  ProcessingTimestamp , 
                  EndDate , 
                  SubmittedNumberOfUncoveredMonths , 
                  SecondaryDrugInsuranceFlag , 
                  SecondaryRxID , 
                  SecondaryRxGroup , 
                  EGHP , 
                  PartD_LowIncomePremiumSubsidyLevel , 
                  LowIncomeCoPayCategory , 
                  LowIncomePeriodEffectiveDate , 
                  PartD_LateEnrollmentPenaltyAmount , 
                  PartD_LateEnrollmentPenaltyWaivedAmount , 
                  PartD_LateEnrollmentPenaltySubsidyAmount , 
                  LowIncomePartD_PremiumSubsidyAmount , 
                  PartD_RxBIN , 
                  PartD_RxPCN , 
                  PartD_RxGroup , 
                  PartD_RxID , 
                  SecondaryRxBIN , 
                  SecondaryRxPCN , 
                  DeMinimisDifferentialAmount , 
                  MSPStatusFlag , 
                  LowIncomePeriodEndDate , 
                  LowIncomeSubsidySourceCode , 
                  EnrolleeTypeFlagPBPLevel , 
                  ApplicationDateIndicator , 
                  TRCShortName , 
                  DisenrollmentReasonCode , 
                  MMPOptOutFlag , 
                  CleanUpID , 
                  POSDrugEditUpdateDeleteFlag , 
                  POSDrugEditStatus , 
                  POSDrugEditClass , 
                  POSDrugEditCode , 
                  NotificationDate , 
                  ImplementationDate , 
                  TerminationDate , 
                  NotificationPOSDrugEditCode , 
                  SystemAssignedTransactionTrackingID , 
                  PlanAssignedTransactionTrackingID , 
                  HashDiff , 
                  LoadDate , 
                  RecordSource 
                ) 
                SELECT DISTINCT 
                        m.S_TRR_RK , 
                        m.H_TRR_RK , 
                        m.HICN , 
                        m.Surname , 
                        m.FirstName , 
                        m.MiddleInitial , 
                        m.GenderCode , 
                        m.DOB , 
                        m.RecordType , 
                        m.ContractNumber , 
                        m.StateCode , 
                        m.CountyCode , 
                        m.DisabilityIndicator , 
                        m.HospiceIndicator , 
                        m.Institutional_NHC_HC_BS_Indicator , 
                        m.ESRDIndicator , 
                        m.TransactionReplyCode , 
                        m.TransactionTypeCode , 
                        m.EntitlementTypeCode , 
                        m.EffectiveDate , 
                        m.WAIndicator , 
                        m.PlanBenefitPackageID , 
                        m.TransactionDate , 
                        m.UIInitiatedChangeFlag , 
                        m.TRCValue , 
                        m.DistrictOfficeCode , 
                        m.PrevPartD_Contract_PBP_ForTroopTransfer , 
                        m.SourceID , 
                        m.PriorPlanBenefitPackageID , 
                        m.ApplicationDate , 
                        m.UIUserOrganizationDesignation , 
                        m.OutOfAreaFlag , 
                        m.SegmentNumber , 
                        m.PartC_BeneficiaryPremium , 
                        m.PartD_BeneficiaryPremium , 
                        m.ElectionType , 
                        m.EnrollmentSource , 
                        m.PartD_OptOutFlag , 
                        m.PremiumWithholdOption_PartsC_D , 
                        m.CumulativeNumberOfUncoveredMonths , 
                        m.CreditableCoverageFlag , 
                        m.EmployerSubsidyOverrideFlag , 
                        m.ProcessingTimestamp , 
                        m.EndDate , 
                        m.SubmittedNumberOfUncoveredMonths , 
                        m.SecondaryDrugInsuranceFlag , 
                        m.SecondaryRxID , 
                        m.SecondaryRxGroup , 
                        m.EGHP , 
                        m.PartD_LowIncomePremiumSubsidyLevel , 
                        m.LowIncomeCoPayCategory , 
                        m.LowIncomePeriodEffectiveDate , 
                        m.PartD_LateEnrollmentPenaltyAmount , 
                        m.PartD_LateEnrollmentPenaltyWaivedAmount , 
                        m.PartD_LateEnrollmentPenaltySubsidyAmount , 
                        m.LowIncomePartD_PremiumSubsidyAmount , 
                        m.PartD_RxBIN , 
                        m.PartD_RxPCN , 
                        m.PartD_RxGroup , 
                        m.PartD_RxID , 
                        m.SecondaryRxBIN , 
                        m.SecondaryRxPCN , 
                        m.DeMinimisDifferentialAmount , 
                        m.MSPStatusFlag , 
                        m.LowIncomePeriodEndDate , 
                        m.LowIncomeSubsidySourceCode , 
                        m.EnrolleeTypeFlagPBPLevel , 
                        m.ApplicationDateIndicator , 
                        m.TRCShortName , 
                        m.DisenrollmentReasonCode , 
                        m.MMPOptOutFlag , 
                        m.CleanUpID , 
                        m.POSDrugEditUpdateDeleteFlag , 
                        m.POSDrugEditStatus , 
                        m.POSDrugEditClass , 
                        m.POSDrugEditCode , 
                        m.NotificationDate , 
                        m.ImplementationDate , 
                        m.TerminationDate , 
                        m.NotificationPOSDrugEditCode , 
                        m.SystemAssignedTransactionTrackingID , 
                        m.PlanAssignedTransactionTrackingID , 
                        m.S_TRR_HashDiff , 
                        @CurrentDate , 
                        m.FileName 
                FROM    CHSStaging.dbo.TRRStaging m 
                        LEFT JOIN dbo.S_TRR s ON m.H_TRR_RK = s.H_TRR_RK 
                                                 AND s.RecordEndDate IS NULL 
                                                 AND m.S_TRR_HashDiff = s.HashDiff 
                WHERE   s.S_TRR_RK IS NULL;  
 
			  
	   --RECORD END DATE CLEANUP 
        UPDATE  dbo.S_TRR 
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate)) 
                                  FROM      dbo.S_TRR AS z 
                                  WHERE     z.H_TRR_RK = a.H_TRR_RK 
                                            AND z.LoadDate > a.LoadDate 
                                ) 
        FROM    dbo.S_TRR a 
        WHERE   a.RecordEndDate IS NULL; 
			  
	   --LOAD S_TRRVERBATIM SATELLITE 
        INSERT  INTO dbo.S_TRRVerbatim 
                ( S_TRRVerbatim_RK , 
                  H_TRRVerbatim_RK , 
                  HICN , 
                  Surname , 
                  FirstName , 
                  MiddleInitial , 
                  GenderCode , 
                  DOB , 
                  RecordType , 
                  ContractNumber , 
                  PlanTransactionText , 
                  TransactionAcceptRejectStatus , 
                  SystemAssignedTransactionTrackingID , 
                  PlanAssignedTransactionTrackingID , 
                  HashDiff , 
                  LoadDate , 
                  RecordSource  
			 ) 
                SELECT DISTINCT 
                        t.S_TRRVerbatim_RK , 
                        t.H_TRRVerbatim_RK , 
                        t.HICN , 
                        t.Surname , 
                        t.FirstName , 
                        t.MiddleInitial , 
                        t.GenderCode , 
                        t.DOB , 
                        t.RecordType , 
                        t.ContractNumber , 
                        t.PlanTransactionText , 
                        t.TransactionAcceptRejectStatus , 
                        t.SystemAssignedTransactionTrackingID , 
                        t.PlanAssignedTransactionTrackingID , 
                        t.S_TRRVerbatim_HashDiff , 
                        @CurrentDate , 
                        t.FileName 
                FROM    CHSStaging.dbo.TRRVerbatimStaging t 
                        LEFT JOIN dbo.S_TRRVerbatim s ON t.H_TRRVerbatim_RK = s.H_TRRVerbatim_RK 
                                                         AND s.RecordEndDate IS NULL 
                                                         AND t.S_TRRVerbatim_HashDiff = s.HashDiff 
                WHERE   s.S_TRRVerbatim_RK IS NULL;  
 
	   --RECORD END DATE CLEANUP 
        UPDATE  dbo.S_TRRVerbatim 
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate)) 
                                  FROM      dbo.S_TRRVerbatim AS z 
                                  WHERE     z.H_TRRVerbatim_RK = a.H_TRRVerbatim_RK 
                                            AND z.LoadDate > a.LoadDate 
                                ) 
        FROM    dbo.S_TRRVerbatim a 
        WHERE   a.RecordEndDate IS NULL; 
 
	   --LOAD MEMBER DEMO SATELLITE FROM TRR 
        INSERT  INTO dbo.S_MemberDemo 
                ( S_MemberDemo_RK , 
                  LoadDate , 
                  H_Member_RK , 
                  FirstName , 
                  LastName , 
                  MiddleInitial , 
                  Gender , 
                  DOB , 
                  HashDiff , 
                  RecordSource  
	           ) 
                SELECT DISTINCT 
                        t.S_MemberDemo_RK , 
                        @CurrentDate , 
                        t.H_Member_RK , 
                        t.FirstName , 
                        t.Surname , 
                        t.MiddleInitial , 
                        t.GenderCode , 
                        t.DOB , 
                        t.S_MemberDemo_HashDiff , 
                        t.FileName 
                FROM    CHSStaging.dbo.TRRStaging t 
                        LEFT JOIN dbo.S_MemberDemo s ON t.H_Member_RK = s.H_Member_RK 
                                                        AND s.RecordEndDate IS NULL 
                                                        AND s.HashDiff = t.S_MemberDemo_HashDiff 
                WHERE   s.S_MemberDemo_RK IS NULL 
                        AND t.H_Member_RK IS NOT NULL; 
	    
	   --RECORD END DATE CLEANUP 
        UPDATE  dbo.S_MemberDemo 
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate)) 
                                  FROM      dbo.S_MemberDemo AS z 
                                  WHERE     z.H_Member_RK = a.H_Member_RK 
                                            AND z.LoadDate > a.LoadDate 
                                ) 
        FROM    dbo.S_MemberDemo a 
        WHERE   a.RecordEndDate IS NULL; 
	    
	   --LOAD MEMBER DEMO SATELLITE FROM TRRVERBATIM 
        INSERT  INTO dbo.S_MemberDemo 
                ( S_MemberDemo_RK , 
                  LoadDate , 
                  H_Member_RK , 
                  FirstName , 
                  LastName , 
                  MiddleInitial , 
                  Gender , 
                  DOB , 
                  HashDiff , 
                  RecordSource  
	           ) 
                SELECT DISTINCT 
                        t.S_MemberDemo_RK , 
                        @CurrentDate , 
                        t.H_Member_RK , 
                        t.FirstName , 
                        t.Surname , 
                        t.MiddleInitial , 
                        t.GenderCode , 
                        t.DOB , 
                        t.S_MemberDemo_HashDiff , 
                        t.FileName 
                FROM    CHSStaging.dbo.TRRVerbatimStaging t 
                        LEFT JOIN dbo.S_MemberDemo s ON t.H_Member_RK = s.H_Member_RK 
                                                        AND s.RecordEndDate IS NULL 
                                                        AND s.HashDiff = t.S_MemberDemo_HashDiff 
                WHERE   s.S_MemberDemo_RK IS NULL 
                        AND t.H_Member_RK IS NOT NULL; 
 
	   --RECORD END DATE CLEANUP 
        UPDATE  dbo.S_MemberDemo 
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate)) 
                                  FROM      dbo.S_MemberDemo AS z 
                                  WHERE     z.H_Member_RK = a.H_Member_RK 
                                            AND z.LoadDate > a.LoadDate 
                                ) 
        FROM    dbo.S_MemberDemo a 
        WHERE   a.RecordEndDate IS NULL; 
 
    END; 
 
    
GO
