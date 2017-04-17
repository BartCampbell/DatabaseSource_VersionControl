SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
 
-- ============================================= 
-- Author:		Travis Parker 
-- Create date:	02/20/2017 
-- Description:	Splits the Verbatim record types out into a separate table 
-- ============================================= 
CREATE PROCEDURE [dbo].[spTRRSplitRecordTypes] 
AS 
    BEGIN 
	 
        DECLARE @CurrentDate DATETIME = GETDATE(); 
 
        SET NOCOUNT ON; 
 
        BEGIN TRY	 
 
            INSERT  INTO CHSStaging.dbo.TRRVerbatimStaging 
                    ( HICN , 
                      Surname , 
                      FirstName , 
                      MiddleInitial , 
                      GenderCode , 
                      DOB , 
                      RecordType , 
                      ContractNumber , 
                      PlanTransactionText , 
                      Filler , 
                      TransactionAcceptRejectStatus , 
                      SystemAssignedTransactionTrackingID , 
                      PlanAssignedTransactionTrackingID , 
				  FileName , 
				  ClientID , 
				  LoadDate , 
				  H_Member_RK , 
				  CentauriMemberID 
                    ) 
                    SELECT  HICN , 
                            Surname , 
                            FirstName , 
                            MiddleInitial , 
                            GenderCode , 
                            DOB , 
                            RecordType , 
                            ContractNumber , 
                            LEFT(StateCode + CountyCode + DisabilityIndicator + HospiceIndicator + Institutional_NHC_HC_BS_Indicator + ESRDIndicator 
                                 + TransactionReplyCode + TransactionTypeCode + EntitlementTypeCode + EffectiveDate + WAIndicator + PlanBenefitPackageID 
                                 + Filler + TransactionDate + UIInitiatedChangeFlag + TRCValue + DistrictOfficeCode + PrevPartD_Contract_PBP_ForTroopTransfer 
                                 + Filler2 + SourceID + PriorPlanBenefitPackageID + ApplicationDate + UIUserOrganizationDesignation + OutOfAreaFlag 
                                 + SegmentNumber + PartC_BeneficiaryPremium + PartD_BeneficiaryPremium + ElectionType + EnrollmentSource + PartD_OptOutFlag 
                                 + PremiumWithholdOption_PartsC_D + CumulativeNumberOfUncoveredMonths + CreditableCoverageFlag + EmployerSubsidyOverrideFlag 
                                 + ProcessingTimestamp + EndDate + SubmittedNumberOfUncoveredMonths + Filler3 + SecondaryDrugInsuranceFlag + SecondaryRxID 
                                 + SecondaryRxGroup + EGHP + PartD_LowIncomePremiumSubsidyLevel + LowIncomeCoPayCategory + LowIncomePeriodEffectiveDate 
                                 + PartD_LateEnrollmentPenaltyAmount + PartD_LateEnrollmentPenaltyWaivedAmount + PartD_LateEnrollmentPenaltySubsidyAmount 
                                 + LowIncomePartD_PremiumSubsidyAmount + PartD_RxBIN + PartD_RxPCN + PartD_RxGroup + PartD_RxID + SecondaryRxBIN 
                                 + SecondaryRxPCN + DeMinimisDifferentialAmount + MSPStatusFlag + LowIncomePeriodEndDate + LowIncomeSubsidySourceCode 
                                 + EnrolleeTypeFlagPBPLevel + ApplicationDateIndicator + TRCShortName + DisenrollmentReasonCode + MMPOptOutFlag + CleanUpID 
                                 + POSDrugEditUpdateDeleteFlag + POSDrugEditStatus + POSDrugEditClass + POSDrugEditCode + NotificationDate + ImplementationDate 
                                 + TerminationDate + NotificationPOSDrugEditCode, 300) AS PlanTransactionText , 
                            LEFT(Filler4, 45) AS Filler , 
                            RIGHT(Filler4, 1) AS TransactionAcceptRejectStatus , 
                            SystemAssignedTransactionTrackingID , 
                            PlanAssignedTransactionTrackingID , 
					   FileName , 
					   ClientID , 
					   LoadDate , 
					   H_Member_RK , 
					   CentauriMemberID 
                    FROM    CHSStaging.dbo.TRRStaging 
                    WHERE   RecordType = 'P';  
 
            DELETE  FROM CHSStaging.dbo.TRRStaging 
            WHERE   RecordType = 'P'; 
 
        END TRY  
        BEGIN CATCH 
            THROW; 
        END CATCH;  
    END; 
 
 
GO
