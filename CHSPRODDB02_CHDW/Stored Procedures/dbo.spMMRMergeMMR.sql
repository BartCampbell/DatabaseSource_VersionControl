SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




-- =============================================
-- Author:		Travis Parker
-- Create date:	08/01/2016
-- Description:	merges the stage to dim for MMR
-- Usage:			
--		  EXECUTE dbo.spMMRMergeMMR
-- =============================================
CREATE PROC [dbo].[spMMRMergeMMR]
AS
    DECLARE @CurrentDate DATETIME = GETDATE();

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN
    
        MERGE INTO fact.MMR AS t
        USING
            ( SELECT  DISTINCT
                        c.CentauriClientID ,
                        s.CentauriMemberID ,
                        s.MCO_Contract_Nbr ,
                        CONVERT(INT, s.File_Run_Date) AS File_Run_Date ,
                        s.Payment_YYYYMM ,
                        s.HICN_Nbr ,
                        s.Last_Name ,
                        s.First_Initial ,
                        s.Gender ,
                        CONVERT(INT, s.Birth_Date) AS Birth_Date ,
                        s.Age_Group ,
                        s.State_County_Code ,
                        s.Out_Of_Area_Ind ,
                        s.Part_A_Entitle_Ind ,
                        s.Part_B_Entitle_Ind ,
                        s.Hospice_Ind ,
                        s.ESRD_Ind ,
                        s.Aged_Disabled_MSP_Ind ,
                        s.Institutional_Ind ,
                        s.NHC_Ind ,
                        s.New_Medicare_Benificiary_Medicaid_Status ,
                        s.LTI_Flg ,
                        s.Medicaid_Ind ,
                        s.PIP_DCG_Catg ,
                        s.Default_Risk_Factor_Code ,
                        CONVERT(NUMERIC(12, 4), s.Risk_Adjust_Factor_A) AS Risk_Adjust_Factor_A ,
                        CONVERT(NUMERIC(12, 4), s.Risk_Adjust_Factor_B) AS Risk_Adjust_Factor_B ,
                        CONVERT(INT, s.Nbr_of_Pay_Adjust_Mths_Part_A) AS Nbr_of_Pay_Adjust_Mths_Part_A ,
                        CONVERT(INT, s.Nbr_of_Pay_Adjust_Mths_Part_B) AS Nbr_of_Pay_Adjust_Mths_Part_B ,
                        s.Adjust_Reason_Code ,
                        s.Pay_Adjust_MSA_Start_Date ,
                        s.Pay_Adjust_MSA_End_Date ,
                        CONVERT(NUMERIC(12, 4), s.Demographic_Pay_Adjust_Amt_A) AS Demographic_Pay_Adjust_Amt_A ,
                        CONVERT(NUMERIC(12, 4), s.Demographic_Pay_Adjust_Amt_B) AS Demographic_Pay_Adjust_Amt_B ,
                        CONVERT(NUMERIC(12, 4), s.Monthly_Pay_Adjust_Amt_A) AS Monthly_Pay_Adjust_Amt_A ,
                        CONVERT(NUMERIC(12, 4), s.Monthly_Pay_Adjust_Amt_B) AS Monthly_Pay_Adjust_Amt_B ,
                        CONVERT(NUMERIC(12, 4), s.LIS_Premium_Subsidy) AS LIS_Premium_Subsidy ,
                        s.ESRD_MSP_Flg ,
                        CONVERT(NUMERIC(12, 4), REPLACE(s.MSA_Part_A_Deposit_Recovery_Amt, ' ', '0')) AS MSA_Part_A_Deposit_Recovery_Amt ,
                        CONVERT(NUMERIC(12, 4), REPLACE(s.MSA_Part_B_Deposit_Recovery_Amt, ' ', '0')) AS MSA_Part_B_Deposit_Recovery_Amt ,
                        CONVERT(INT, s.Nbr_of_MSA_Deposit_Recovery_Mths) AS Nbr_of_MSA_Deposit_Recovery_Mths ,
                        s.Current_Medicaid_Status ,
                        s.Risk_Adjuster_Age_Group ,
                        s.Previous_Disable_Ratio ,
                        s.De_Minimis ,
                        s.Beneficiary_Dual_Part_D_Enroll_Status_Flg ,
                        s.Plan_Benefit_Pkg_Id ,
                        s.Race_Ind ,
                        s.RA_Factor_Type_Code ,
                        s.Frailty_Ind ,
                        s.Orig_Reason_for_Entitle_Code ,
                        s.Lag_Ind ,
                        s.Segment_ID ,
                        s.Enrollment_Source ,
                        s.EGHP_Flg ,
                        CONVERT(NUMERIC(12, 4), s.Part_C_Premium_Part_A_Amt) AS Part_C_Premium_Part_A_Amt ,
                        CONVERT(NUMERIC(12, 4), s.Part_C_Premium_Part_B_Amt) AS Part_C_Premium_Part_B_Amt ,
                        CONVERT(NUMERIC(12, 4), s.Rebate_Part_A_Cost_Sharing_Reduct) AS Rebate_Part_A_Cost_Sharing_Reduct ,
                        CONVERT(NUMERIC(12, 4), s.Rebate_Part_B_Cost_Sharing_Reduct) AS Rebate_Part_B_Cost_Sharing_Reduct ,
                        CONVERT(NUMERIC(12, 4), s.Rebate_Other_Part_A_Mandat_Suplmt_Benefits) AS Rebate_Other_Part_A_Mandat_Suplmt_Benefits ,
                        CONVERT(NUMERIC(12, 4), s.Rebate_Other_Part_B_Mandat_Suplmt_Benefits) AS Rebate_Other_Part_B_Mandat_Suplmt_Benefits ,
                        CONVERT(NUMERIC(12, 4), s.Rebate_Part_B_Prem_Reduct_Part_A_Amt) AS Rebate_Part_B_Prem_Reduct_Part_A_Amt ,
                        CONVERT(NUMERIC(12, 4), s.Rebate_Part_B_Prem_Reduct_Part_B_Amt) AS Rebate_Part_B_Prem_Reduct_Part_B_Amt ,
                        CONVERT(NUMERIC(12, 4), s.Rebate_Part_D_Suplmt_Benefit_Part_A_Amt) AS Rebate_Part_D_Suplmt_Benefit_Part_A_Amt ,
                        CONVERT(NUMERIC(12, 4), s.Rebate_Part_D_Suplmt_Benefit_Part_B_Amt) AS Rebate_Part_D_Suplmt_Benefit_Part_B_Amt ,
                        CONVERT(NUMERIC(12, 4), s.Total_Part_A_MA_Payment) AS Total_Part_A_MA_Payment ,
                        CONVERT(NUMERIC(12, 4), s.Total_Part_B_MA_Payment) AS Total_Part_B_MA_Payment ,
                        CONVERT(NUMERIC(12, 4), s.Total_MA_Payment_Amt) AS Total_MA_Payment_Amt ,
                        s.Part_D_RA_Factor ,
                        s.Part_D_Low_Income_Indicator ,
                        s.Part_D_Low_Income_Multiplier ,
                        s.Part_D_Long_Term_Institut_Ind ,
                        s.Part_D_Long_Term_Institut_Multi ,
                        CONVERT(NUMERIC(12, 4), s.Rebate_for_Part_D_Basic_Prem_Reduct) AS Rebate_for_Part_D_Basic_Prem_Reduct ,
                        CONVERT(NUMERIC(12, 4), s.Part_D_Basic_Premium_Amount) AS Part_D_Basic_Premium_Amount ,
                        CONVERT(NUMERIC(12, 4), s.Part_D_Direct_Subsidy_Mthly_Pay_Amt) AS Part_D_Direct_Subsidy_Mthly_Pay_Amt ,
                        CONVERT(NUMERIC(12, 4), s.Reinsurance_Subsidy_Amount) AS Reinsurance_Subsidy_Amount ,
                        CONVERT(NUMERIC(12, 4), s.LIS_Cost_Sharing_Amount) AS LIS_Cost_Sharing_Amount ,
                        CONVERT(NUMERIC(12, 4), s.Total_Part_D_Payment) AS Total_Part_D_Payment ,
                        CONVERT(INT, s.Nbr_of_Paymt_Adjustmt_Mths_Part_D) AS Nbr_of_Paymt_Adjustmt_Mths_Part_D ,
                        CONVERT(NUMERIC(12, 4), s.PACE_Premium_Add_On) AS PACE_Premium_Add_On ,
                        CONVERT(NUMERIC(12, 4), s.PACE_Cost_Sharing_Add_On) AS PACE_Cost_Sharing_Add_On ,
                        s.Part_C_Frailty_Score_Factor ,
                        s.MSP_Factor ,
                        CONVERT(NUMERIC(12, 4), s.MSP_Reduct_Adjustmt_Amt_Part_A) AS MSP_Reduct_Adjustmt_Amt_Part_A ,
                        CONVERT(NUMERIC(12, 4), s.MSP_Reduct_Adjustmt_Amt_Part_B) AS MSP_Reduct_Adjustmt_Amt_Part_B ,
                        s.Medicaid_Dual_Status_Code ,
                        CONVERT(NUMERIC(12, 4), s.Part_D_Coverage_Gap_Discount_Amt) AS Part_D_Coverage_Gap_Discount_Amt ,
                        s.Part_D_RA_Factor_Type ,
                        s.Default_Part_D_Risk_Factor_Code ,
                        CONVERT(NUMERIC(12, 4), s.Part_A_Risk_Adjstd_Mthly_Rate_Amt_for_Pymt_Adj) AS Part_A_Risk_Adjstd_Mthly_Rate_Amt_for_Pymt_Adj ,
                        CONVERT(NUMERIC(12, 4), s.Part_B_Risk_Adjstd_Mthly_Rate_Amt_for_Pymt_Adj) AS Part_B_Risk_Adjstd_Mthly_Rate_Amt_for_Pymt_Adj ,
                        CONVERT(NUMERIC(12, 4), s.Part_D_Direct_Subsidy_Mthly_Rate_Amt_for_Pymt_Adj) AS Part_D_Direct_Subsidy_Mthly_Rate_Amt_for_Pymt_Adj ,
                        s.Cleanup_ID ,
                        s.RecordSource ,
                        c.ClientID ,
                        m.MemberID ,
                        s.Sequence
              FROM      stage.MMR s
                        INNER JOIN dim.Client c ON s.ClientID = c.CentauriClientID
                        INNER JOIN dim.Member m ON m.CentauriMemberID = s.CentauriMemberID
            ) AS s
        ON t.FileName = s.RecordSource
            AND t.ContractNbr = s.MCO_Contract_Nbr
            AND t.FileRunDate = s.File_Run_Date
            AND t.PaymentDate = s.Payment_YYYYMM
            AND t.HICN = s.HICN_Nbr
            AND t.Sequence = s.Sequence
        WHEN MATCHED AND ( ISNULL(t.LastName, '') <> ISNULL(s.Last_Name, '')
                           OR ISNULL(t.FirstInitial, '') <> ISNULL(s.First_Initial, '')
                           OR ISNULL(t.Gender, '') <> ISNULL(s.Gender, '')
                           OR ISNULL(t.BirthDate, '') <> ISNULL(s.Birth_Date, '')
                           OR ISNULL(t.Age_Group, '') <> ISNULL(s.Age_Group, '')
                           OR ISNULL(t.StateCountyCode, '') <> ISNULL(s.State_County_Code, '')
                           OR ISNULL(t.Out_Of_Area_Ind, '') <> ISNULL(s.Out_Of_Area_Ind, '')
                           OR ISNULL(t.PartA_Entitle_Ind, '') <> ISNULL(s.Part_A_Entitle_Ind, '')
                           OR ISNULL(t.PartB_Entitle_Ind, '') <> ISNULL(s.Part_B_Entitle_Ind, '')
                           OR ISNULL(t.HospiceInd, '') <> ISNULL(s.Hospice_Ind, '')
                           OR ISNULL(t.ESRDInd, '') <> ISNULL(s.ESRD_Ind, '')
                           OR ISNULL(t.AgedDisabledMSPInd, '') <> ISNULL(s.Aged_Disabled_MSP_Ind, '')
                           OR ISNULL(t.InstitutionalInd, '') <> ISNULL(s.Institutional_Ind, '')
                           OR ISNULL(t.NHCInd, '') <> ISNULL(s.NHC_Ind, '')
                           OR ISNULL(t.NewMedicareBenificiaryMedicaidStatus, '') <> ISNULL(s.New_Medicare_Benificiary_Medicaid_Status, '')
                           OR ISNULL(t.LTIFlg, '') <> ISNULL(s.LTI_Flg, '')
                           OR ISNULL(t.MedicaidInd, '') <> ISNULL(s.Medicaid_Ind, '')
                           OR ISNULL(t.PIPDCGCatg, '') <> ISNULL(s.PIP_DCG_Catg, '')
                           OR ISNULL(t.Default_Risk_Factor_Code, '') <> ISNULL(s.Default_Risk_Factor_Code, '')
                           OR ISNULL(t.Risk_Adjust_FactorA, '') <> ISNULL(s.Risk_Adjust_Factor_A, '')
                           OR ISNULL(t.Risk_Adjust_FactorB, '') <> ISNULL(s.Risk_Adjust_Factor_B, '')
                           OR ISNULL(t.Nbr_of_Pay_Adjust_Mths_Part_A, '') <> ISNULL(s.Nbr_of_Pay_Adjust_Mths_Part_A, '')
                           OR ISNULL(t.Nbr_of_Pay_Adjust_Mths_Part_B, '') <> ISNULL(s.Nbr_of_Pay_Adjust_Mths_Part_B, '')
                           OR ISNULL(t.Adjust_Reason_Code, '') <> ISNULL(s.Adjust_Reason_Code, '')
                           OR ISNULL(t.Pay_Adjust_MSA_Start_Date, '') <> ISNULL(s.Pay_Adjust_MSA_Start_Date, '')
                           OR ISNULL(t.Pay_Adjust_MSA_End_Date, '') <> ISNULL(s.Pay_Adjust_MSA_End_Date, '')
                           OR ISNULL(t.Demographic_Pay_Adjust_Amt_A, '') <> ISNULL(s.Demographic_Pay_Adjust_Amt_A, '')
                           OR ISNULL(t.Demographic_Pay_Adjust_Amt_B, '') <> ISNULL(s.Demographic_Pay_Adjust_Amt_B, '')
                           OR ISNULL(t.Monthly_Pay_Adjust_Amt_A, '') <> ISNULL(s.Monthly_Pay_Adjust_Amt_A, '')
                           OR ISNULL(t.Monthly_Pay_Adjust_Amt_B, '') <> ISNULL(s.Monthly_Pay_Adjust_Amt_B, '')
                           OR ISNULL(t.LIS_Premium_Subsidy, '') <> ISNULL(s.LIS_Premium_Subsidy, '')
                           OR ISNULL(t.ESRD_MSP_Flg, '') <> ISNULL(s.ESRD_MSP_Flg, '')
                           OR ISNULL(t.MSA_Part_A_Deposit_Recovery_Amt, '') <> ISNULL(s.MSA_Part_A_Deposit_Recovery_Amt, '')
                           OR ISNULL(t.MSA_Part_B_Deposit_Recovery_Amt, '') <> ISNULL(s.MSA_Part_B_Deposit_Recovery_Amt, '')
                           OR ISNULL(t.Nbr_of_MSA_Deposit_Recovery_Mths, '') <> ISNULL(s.Nbr_of_MSA_Deposit_Recovery_Mths, '')
                           OR ISNULL(t.Current_Medicaid_Status, '') <> ISNULL(s.Current_Medicaid_Status, '')
                           OR ISNULL(t.Risk_Adjsuter_Age_Group, '') <> ISNULL(s.Risk_Adjuster_Age_Group, '')
                           OR ISNULL(t.Prevous_Disable_Ratio, '') <> ISNULL(s.Previous_Disable_Ratio, '')
                           OR ISNULL(t.De_Minimis, '') <> ISNULL(s.De_Minimis, '')
                           OR ISNULL(t.Beneficiary_Dual_Part_D_Enroll_Status_Flg, '') <> ISNULL(s.Beneficiary_Dual_Part_D_Enroll_Status_Flg, '')
                           OR ISNULL(t.PlanBenefitPkg_Id, '') <> ISNULL(s.Plan_Benefit_Pkg_Id, '')
                           OR ISNULL(t.RaceInd, '') <> ISNULL(s.Race_Ind, '')
                           OR ISNULL(t.RAFactorTypeCode, '') <> ISNULL(s.RA_Factor_Type_Code, '')
                           OR ISNULL(t.FrailtyInd, '') <> ISNULL(s.Frailty_Ind, '')
                           OR ISNULL(t.OrigReasonforEntitle_Code, '') <> ISNULL(s.Orig_Reason_for_Entitle_Code, '')
                           OR ISNULL(t.LagInd, '') <> ISNULL(s.Lag_Ind, '')
                           OR ISNULL(t.SegmentID, '') <> ISNULL(s.Segment_ID, '')
                           OR ISNULL(t.EnrollmentSource, '') <> ISNULL(s.Enrollment_Source, '')
                           OR ISNULL(t.EGHPFlg, '') <> ISNULL(s.EGHP_Flg, '')
                           OR ISNULL(t.PartC_Premium_PartA_Amt, '') <> ISNULL(s.Part_C_Premium_Part_A_Amt, '')
                           OR ISNULL(t.PartC_Premium_PartB_Amt, '') <> ISNULL(s.Part_C_Premium_Part_B_Amt, '')
                           OR ISNULL(t.Rebate_PartA_Cost_Sharing_Reduct, '') <> ISNULL(s.Rebate_Part_A_Cost_Sharing_Reduct, '')
                           OR ISNULL(t.Rebate_PartB_Cost_Sharing_Reduct, '') <> ISNULL(s.Rebate_Part_B_Cost_Sharing_Reduct, '')
                           OR ISNULL(t.Rebate_Other_PartA_Mandat_Suplmt_Benefits, '') <> ISNULL(s.Rebate_Other_Part_A_Mandat_Suplmt_Benefits, '')
                           OR ISNULL(t.Rebate_PartB_Prem_Reduct_Part_A_Amt, '') <> ISNULL(s.Rebate_Part_B_Prem_Reduct_Part_A_Amt, '')
                           OR ISNULL(t.Rebate_PartB_Prem_Reduct_Part_B_Amt, '') <> ISNULL(s.Rebate_Part_B_Prem_Reduct_Part_B_Amt, '')
                           OR ISNULL(t.Rebate_PartD_Suplmt_Benefit_Part_A_Amt, '') <> ISNULL(s.Rebate_Part_D_Suplmt_Benefit_Part_A_Amt, '')
                           OR ISNULL(t.Rebate_PartD_Suplmt_Benefit_Part_B_Amt, '') <> ISNULL(s.Rebate_Part_D_Suplmt_Benefit_Part_B_Amt, '')
                           OR ISNULL(t.Total_PartA_MA_Payment, '') <> ISNULL(s.Total_Part_A_MA_Payment, '')
                           OR ISNULL(t.Total_PartB_MA_Payment, '') <> ISNULL(s.Total_Part_B_MA_Payment, '')
                           OR ISNULL(t.Total_MA_Payment_Amt, '') <> ISNULL(s.Total_MA_Payment_Amt, '')
                           OR ISNULL(t.PartD_RA_Factor, '') <> ISNULL(s.Part_D_RA_Factor, '')
                           OR ISNULL(t.PartD_Low_Income_Indicator, '') <> ISNULL(s.Part_D_Low_Income_Indicator, '')
                           OR ISNULL(t.PartD_Low_Income_Multiplier, '') <> ISNULL(s.Part_D_Low_Income_Multiplier, '')
                           OR ISNULL(t.PartD_Long_Term_Institut_Ind, '') <> ISNULL(s.Part_D_Long_Term_Institut_Ind, '')
                           OR ISNULL(t.PartD_Long_Term_Institut_Multi, '') <> ISNULL(s.Part_D_Long_Term_Institut_Multi, '')
                           OR ISNULL(t.Rebate_for_PartD_Basic_Prem_Reduct, '') <> ISNULL(s.Rebate_for_Part_D_Basic_Prem_Reduct, '')
                           OR ISNULL(t.PartD_Basic_Premium_Amount, '') <> ISNULL(s.Part_D_Basic_Premium_Amount, '')
                           OR ISNULL(t.PartD_Direct_Subsidy_Mthly_Pay_Amt, '') <> ISNULL(s.Part_D_Direct_Subsidy_Mthly_Pay_Amt, '')
                           OR ISNULL(t.ReinsuranceSubsidyAmount, '') <> ISNULL(s.Reinsurance_Subsidy_Amount, '')
                           OR ISNULL(t.LIS_CostSharingAmount, '') <> ISNULL(s.LIS_Cost_Sharing_Amount, '')
                           OR ISNULL(t.Total_PartD_Payment, '') <> ISNULL(s.Total_Part_D_Payment, '')
                           OR ISNULL(t.NbrPaymtAdjustmtMthsPartD, '') <> ISNULL(s.Nbr_of_Paymt_Adjustmt_Mths_Part_D, '')
                           OR ISNULL(t.PACE_PremiumAddOn, '') <> ISNULL(s.PACE_Premium_Add_On, '')
                           OR ISNULL(t.PACE_CostSharingAddOn, '') <> ISNULL(s.PACE_Cost_Sharing_Add_On, '')
                           OR ISNULL(t.PartC_FrailtyScoreFactor, '') <> ISNULL(s.Part_C_Frailty_Score_Factor, '')
                           OR ISNULL(t.MSPFactor, '') <> ISNULL(s.MSP_Factor, '')
                           OR ISNULL(t.MSPReduct_Adjustmt_Amt_PartA, '') <> ISNULL(s.MSP_Reduct_Adjustmt_Amt_Part_A, '')
                           OR ISNULL(t.MSPReduct_Adjustmt_Amt_PartB, '') <> ISNULL(s.MSP_Reduct_Adjustmt_Amt_Part_B, '')
                           OR ISNULL(t.MedicaidDualStatus_Code, '') <> ISNULL(s.Medicaid_Dual_Status_Code, '')
                           OR ISNULL(t.PartD_Coverage_Gap_Discount_Amt, '') <> ISNULL(s.Part_D_Coverage_Gap_Discount_Amt, '')
                           OR ISNULL(t.PartD_RAFactorType, '') <> ISNULL(s.Part_D_RA_Factor_Type, '')
                           OR ISNULL(t.Default_PartD_RiskFactor_Code, '') <> ISNULL(s.Default_Part_D_Risk_Factor_Code, '')
                           OR ISNULL(t.PartA_Risk_Adjstd_Mthly_Rate_Amt_for_Pymt_Adj, '') <> ISNULL(s.Part_A_Risk_Adjstd_Mthly_Rate_Amt_for_Pymt_Adj, '')
                           OR ISNULL(t.PartB_Risk_Adjstd_Mthly_Rate_Amt_for_Pymt_Adj, '') <> ISNULL(s.Part_B_Risk_Adjstd_Mthly_Rate_Amt_for_Pymt_Adj, '')
                           OR ISNULL(t.PartD_Direct_Subsidy_Mthly_Rate_Amt_for_Pymt_Adj, '') <> ISNULL(s.Part_D_Direct_Subsidy_Mthly_Rate_Amt_for_Pymt_Adj, '')
                           OR ISNULL(t.CleanupID, '') <> ISNULL(s.Cleanup_ID, '')
                         ) THEN
            UPDATE SET
                    t.LastName = s.Last_Name ,
                    t.FirstInitial = s.First_Initial ,
                    t.Gender = s.Gender ,
                    t.BirthDate = s.Birth_Date ,
                    t.Age_Group = s.Age_Group ,
                    t.StateCountyCode = s.State_County_Code ,
                    t.Out_Of_Area_Ind = s.Out_Of_Area_Ind ,
                    t.PartA_Entitle_Ind = s.Part_A_Entitle_Ind ,
                    t.PartB_Entitle_Ind = s.Part_B_Entitle_Ind ,
                    t.HospiceInd = s.Hospice_Ind ,
                    t.ESRDInd = s.ESRD_Ind ,
                    t.AgedDisabledMSPInd = s.Aged_Disabled_MSP_Ind ,
                    t.InstitutionalInd = s.Institutional_Ind ,
                    t.NHCInd = s.NHC_Ind ,
                    t.NewMedicareBenificiaryMedicaidStatus = s.New_Medicare_Benificiary_Medicaid_Status ,
                    t.LTIFlg = s.LTI_Flg ,
                    t.MedicaidInd = s.Medicaid_Ind ,
                    t.PIPDCGCatg = s.PIP_DCG_Catg ,
                    t.Default_Risk_Factor_Code = s.Default_Risk_Factor_Code ,
                    t.Risk_Adjust_FactorA = s.Risk_Adjust_Factor_A ,
                    t.Risk_Adjust_FactorB = s.Risk_Adjust_Factor_B ,
                    t.Nbr_of_Pay_Adjust_Mths_Part_A = s.Nbr_of_Pay_Adjust_Mths_Part_A ,
                    t.Nbr_of_Pay_Adjust_Mths_Part_B = s.Nbr_of_Pay_Adjust_Mths_Part_B ,
                    t.Adjust_Reason_Code = s.Adjust_Reason_Code ,
                    t.Pay_Adjust_MSA_Start_Date = s.Pay_Adjust_MSA_Start_Date ,
                    t.Pay_Adjust_MSA_End_Date = s.Pay_Adjust_MSA_End_Date ,
                    t.Demographic_Pay_Adjust_Amt_A = s.Demographic_Pay_Adjust_Amt_A ,
                    t.Demographic_Pay_Adjust_Amt_B = s.Demographic_Pay_Adjust_Amt_B ,
                    t.Monthly_Pay_Adjust_Amt_A = s.Monthly_Pay_Adjust_Amt_A ,
                    t.Monthly_Pay_Adjust_Amt_B = s.Monthly_Pay_Adjust_Amt_B ,
                    t.LIS_Premium_Subsidy = s.LIS_Premium_Subsidy ,
                    t.ESRD_MSP_Flg = s.ESRD_MSP_Flg ,
                    t.MSA_Part_A_Deposit_Recovery_Amt = s.MSA_Part_A_Deposit_Recovery_Amt ,
                    t.MSA_Part_B_Deposit_Recovery_Amt = s.MSA_Part_B_Deposit_Recovery_Amt ,
                    t.Nbr_of_MSA_Deposit_Recovery_Mths = s.Nbr_of_MSA_Deposit_Recovery_Mths ,
                    t.Current_Medicaid_Status = s.Current_Medicaid_Status ,
                    t.Risk_Adjsuter_Age_Group = s.Risk_Adjuster_Age_Group ,
                    t.Prevous_Disable_Ratio = s.Previous_Disable_Ratio ,
                    t.De_Minimis = s.De_Minimis ,
                    t.Beneficiary_Dual_Part_D_Enroll_Status_Flg = s.Beneficiary_Dual_Part_D_Enroll_Status_Flg ,
                    t.PlanBenefitPkg_Id = s.Plan_Benefit_Pkg_Id ,
                    t.RaceInd = s.Race_Ind ,
                    t.RAFactorTypeCode = s.RA_Factor_Type_Code ,
                    t.FrailtyInd = s.Frailty_Ind ,
                    t.OrigReasonforEntitle_Code = s.Orig_Reason_for_Entitle_Code ,
                    t.LagInd = s.Lag_Ind ,
                    t.SegmentID = s.Segment_ID ,
                    t.EnrollmentSource = s.Enrollment_Source ,
                    t.EGHPFlg = s.EGHP_Flg ,
                    t.PartC_Premium_PartA_Amt = s.Part_C_Premium_Part_A_Amt ,
                    t.PartC_Premium_PartB_Amt = s.Part_C_Premium_Part_B_Amt ,
                    t.Rebate_PartA_Cost_Sharing_Reduct = s.Rebate_Part_A_Cost_Sharing_Reduct ,
                    t.Rebate_PartB_Cost_Sharing_Reduct = s.Rebate_Part_B_Cost_Sharing_Reduct ,
                    t.Rebate_Other_PartA_Mandat_Suplmt_Benefits = s.Rebate_Other_Part_A_Mandat_Suplmt_Benefits ,
                    t.Rebate_PartB_Prem_Reduct_Part_A_Amt = s.Rebate_Part_B_Prem_Reduct_Part_A_Amt ,
                    t.Rebate_PartB_Prem_Reduct_Part_B_Amt = s.Rebate_Part_B_Prem_Reduct_Part_B_Amt ,
                    t.Rebate_PartD_Suplmt_Benefit_Part_A_Amt = s.Rebate_Part_D_Suplmt_Benefit_Part_A_Amt ,
                    t.Rebate_PartD_Suplmt_Benefit_Part_B_Amt = s.Rebate_Part_D_Suplmt_Benefit_Part_B_Amt ,
                    t.Total_PartA_MA_Payment = s.Total_Part_A_MA_Payment ,
                    t.Total_PartB_MA_Payment = s.Total_Part_B_MA_Payment ,
                    t.Total_MA_Payment_Amt = s.Total_MA_Payment_Amt ,
                    t.PartD_RA_Factor = s.Part_D_RA_Factor ,
                    t.PartD_Low_Income_Indicator = s.Part_D_Low_Income_Indicator ,
                    t.PartD_Low_Income_Multiplier = s.Part_D_Low_Income_Multiplier ,
                    t.PartD_Long_Term_Institut_Ind = s.Part_D_Long_Term_Institut_Ind ,
                    t.PartD_Long_Term_Institut_Multi = s.Part_D_Long_Term_Institut_Multi ,
                    t.Rebate_for_PartD_Basic_Prem_Reduct = s.Rebate_for_Part_D_Basic_Prem_Reduct ,
                    t.PartD_Basic_Premium_Amount = s.Part_D_Basic_Premium_Amount ,
                    t.PartD_Direct_Subsidy_Mthly_Pay_Amt = s.Part_D_Direct_Subsidy_Mthly_Pay_Amt ,
                    t.ReinsuranceSubsidyAmount = s.Reinsurance_Subsidy_Amount ,
                    t.LIS_CostSharingAmount = s.LIS_Cost_Sharing_Amount ,
                    t.Total_PartD_Payment = s.Total_Part_D_Payment ,
                    t.NbrPaymtAdjustmtMthsPartD = s.Nbr_of_Paymt_Adjustmt_Mths_Part_D ,
                    t.PACE_PremiumAddOn = s.PACE_Premium_Add_On ,
                    t.PACE_CostSharingAddOn = s.PACE_Cost_Sharing_Add_On ,
                    t.PartC_FrailtyScoreFactor = s.Part_C_Frailty_Score_Factor ,
                    t.MSPFactor = s.MSP_Factor ,
                    t.MSPReduct_Adjustmt_Amt_PartA = s.MSP_Reduct_Adjustmt_Amt_Part_A ,
                    t.MSPReduct_Adjustmt_Amt_PartB = s.MSP_Reduct_Adjustmt_Amt_Part_B ,
                    t.MedicaidDualStatus_Code = s.Medicaid_Dual_Status_Code ,
                    t.PartD_Coverage_Gap_Discount_Amt = s.Part_D_Coverage_Gap_Discount_Amt ,
                    t.PartD_RAFactorType = s.Part_D_RA_Factor_Type ,
                    t.Default_PartD_RiskFactor_Code = s.Default_Part_D_Risk_Factor_Code ,
                    t.PartA_Risk_Adjstd_Mthly_Rate_Amt_for_Pymt_Adj = s.Part_A_Risk_Adjstd_Mthly_Rate_Amt_for_Pymt_Adj ,
                    t.PartB_Risk_Adjstd_Mthly_Rate_Amt_for_Pymt_Adj = s.Part_B_Risk_Adjstd_Mthly_Rate_Amt_for_Pymt_Adj ,
                    t.PartD_Direct_Subsidy_Mthly_Rate_Amt_for_Pymt_Adj = s.Part_D_Direct_Subsidy_Mthly_Rate_Amt_for_Pymt_Adj ,
                    t.CleanupID = s.Cleanup_ID ,
                    t.LastUpdate = @CurrentDate
        WHEN NOT MATCHED BY TARGET THEN
            INSERT ( ClientID ,
                     MemberID ,
                     Sequence ,
                     ContractNbr ,
                     FileRunDate ,
                     PaymentDate ,
                     HICN ,
                     LastName ,
                     FirstInitial ,
                     Gender ,
                     BirthDate ,
                     Age_Group ,
                     StateCountyCode ,
                     Out_Of_Area_Ind ,
                     PartA_Entitle_Ind ,
                     PartB_Entitle_Ind ,
                     HospiceInd ,
                     ESRDInd ,
                     AgedDisabledMSPInd ,
                     InstitutionalInd ,
                     NHCInd ,
                     NewMedicareBenificiaryMedicaidStatus ,
                     LTIFlg ,
                     MedicaidInd ,
                     PIPDCGCatg ,
                     Default_Risk_Factor_Code ,
                     Risk_Adjust_FactorA ,
                     Risk_Adjust_FactorB ,
                     Nbr_of_Pay_Adjust_Mths_Part_A ,
                     Nbr_of_Pay_Adjust_Mths_Part_B ,
                     Adjust_Reason_Code ,
                     Pay_Adjust_MSA_Start_Date ,
                     Pay_Adjust_MSA_End_Date ,
                     Demographic_Pay_Adjust_Amt_A ,
                     Demographic_Pay_Adjust_Amt_B ,
                     Monthly_Pay_Adjust_Amt_A ,
                     Monthly_Pay_Adjust_Amt_B ,
                     LIS_Premium_Subsidy ,
                     ESRD_MSP_Flg ,
                     MSA_Part_A_Deposit_Recovery_Amt ,
                     MSA_Part_B_Deposit_Recovery_Amt ,
                     Nbr_of_MSA_Deposit_Recovery_Mths ,
                     Current_Medicaid_Status ,
                     Risk_Adjsuter_Age_Group ,
                     Prevous_Disable_Ratio ,
                     De_Minimis ,
                     Beneficiary_Dual_Part_D_Enroll_Status_Flg ,
                     PlanBenefitPkg_Id ,
                     RaceInd ,
                     RAFactorTypeCode ,
                     FrailtyInd ,
                     OrigReasonforEntitle_Code ,
                     LagInd ,
                     SegmentID ,
                     EnrollmentSource ,
                     EGHPFlg ,
                     PartC_Premium_PartA_Amt ,
                     PartC_Premium_PartB_Amt ,
                     Rebate_PartA_Cost_Sharing_Reduct ,
                     Rebate_PartB_Cost_Sharing_Reduct ,
                     Rebate_Other_PartA_Mandat_Suplmt_Benefits ,
                     Rebate_Other_PartB_Mandat_Suplmt_Benefits ,
                     Rebate_PartB_Prem_Reduct_Part_A_Amt ,
                     Rebate_PartB_Prem_Reduct_Part_B_Amt ,
                     Rebate_PartD_Suplmt_Benefit_Part_A_Amt ,
                     Rebate_PartD_Suplmt_Benefit_Part_B_Amt ,
                     Total_PartA_MA_Payment ,
                     Total_PartB_MA_Payment ,
                     Total_MA_Payment_Amt ,
                     PartD_RA_Factor ,
                     PartD_Low_Income_Indicator ,
                     PartD_Low_Income_Multiplier ,
                     PartD_Long_Term_Institut_Ind ,
                     PartD_Long_Term_Institut_Multi ,
                     Rebate_for_PartD_Basic_Prem_Reduct ,
                     PartD_Basic_Premium_Amount ,
                     PartD_Direct_Subsidy_Mthly_Pay_Amt ,
                     ReinsuranceSubsidyAmount ,
                     LIS_CostSharingAmount ,
                     Total_PartD_Payment ,
                     NbrPaymtAdjustmtMthsPartD ,
                     PACE_PremiumAddOn ,
                     PACE_CostSharingAddOn ,
                     PartC_FrailtyScoreFactor ,
                     MSPFactor ,
                     MSPReduct_Adjustmt_Amt_PartA ,
                     MSPReduct_Adjustmt_Amt_PartB ,
                     MedicaidDualStatus_Code ,
                     PartD_Coverage_Gap_Discount_Amt ,
                     PartD_RAFactorType ,
                     Default_PartD_RiskFactor_Code ,
                     PartA_Risk_Adjstd_Mthly_Rate_Amt_for_Pymt_Adj ,
                     PartB_Risk_Adjstd_Mthly_Rate_Amt_for_Pymt_Adj ,
                     PartD_Direct_Subsidy_Mthly_Rate_Amt_for_Pymt_Adj ,
                     CleanupID ,
                     FileName ,
                     CreateDate ,
                     LastUpdate
                   )
            VALUES ( s.ClientID ,
                     s.MemberID ,
                     s.Sequence ,
                     s.MCO_Contract_Nbr ,
                     s.File_Run_Date ,
                     s.Payment_YYYYMM ,
                     s.HICN_Nbr ,
                     s.Last_Name ,
                     s.First_Initial ,
                     s.Gender ,
                     s.Birth_Date ,
                     s.Age_Group ,
                     s.State_County_Code ,
                     s.Out_Of_Area_Ind ,
                     s.Part_A_Entitle_Ind ,
                     s.Part_B_Entitle_Ind ,
                     s.Hospice_Ind ,
                     s.ESRD_Ind ,
                     s.Aged_Disabled_MSP_Ind ,
                     s.Institutional_Ind ,
                     s.NHC_Ind ,
                     s.New_Medicare_Benificiary_Medicaid_Status ,
                     s.LTI_Flg ,
                     s.Medicaid_Ind ,
                     s.PIP_DCG_Catg ,
                     s.Default_Risk_Factor_Code ,
                     s.Risk_Adjust_Factor_A ,
                     s.Risk_Adjust_Factor_B ,
                     s.Nbr_of_Pay_Adjust_Mths_Part_A ,
                     s.Nbr_of_Pay_Adjust_Mths_Part_B ,
                     s.Adjust_Reason_Code ,
                     s.Pay_Adjust_MSA_Start_Date ,
                     s.Pay_Adjust_MSA_End_Date ,
                     s.Demographic_Pay_Adjust_Amt_A ,
                     s.Demographic_Pay_Adjust_Amt_B ,
                     s.Monthly_Pay_Adjust_Amt_A ,
                     s.Monthly_Pay_Adjust_Amt_B ,
                     s.LIS_Premium_Subsidy ,
                     s.ESRD_MSP_Flg ,
                     s.MSA_Part_A_Deposit_Recovery_Amt ,
                     s.MSA_Part_B_Deposit_Recovery_Amt ,
                     s.Nbr_of_MSA_Deposit_Recovery_Mths ,
                     s.Current_Medicaid_Status ,
                     s.Risk_Adjuster_Age_Group ,
                     s.Previous_Disable_Ratio ,
                     s.De_Minimis ,
                     s.Beneficiary_Dual_Part_D_Enroll_Status_Flg ,
                     s.Plan_Benefit_Pkg_Id ,
                     s.Race_Ind ,
                     s.RA_Factor_Type_Code ,
                     s.Frailty_Ind ,
                     s.Orig_Reason_for_Entitle_Code ,
                     s.Lag_Ind ,
                     s.Segment_ID ,
                     s.Enrollment_Source ,
                     s.EGHP_Flg ,
                     s.Part_C_Premium_Part_A_Amt ,
                     s.Part_C_Premium_Part_B_Amt ,
                     s.Rebate_Part_A_Cost_Sharing_Reduct ,
                     s.Rebate_Part_B_Cost_Sharing_Reduct ,
                     s.Rebate_Other_Part_A_Mandat_Suplmt_Benefits ,
                     s.Rebate_Other_Part_B_Mandat_Suplmt_Benefits ,
                     s.Rebate_Part_B_Prem_Reduct_Part_A_Amt ,
                     s.Rebate_Part_B_Prem_Reduct_Part_B_Amt ,
                     s.Rebate_Part_D_Suplmt_Benefit_Part_A_Amt ,
                     s.Rebate_Part_D_Suplmt_Benefit_Part_B_Amt ,
                     s.Total_Part_A_MA_Payment ,
                     s.Total_Part_B_MA_Payment ,
                     s.Total_MA_Payment_Amt ,
                     s.Part_D_RA_Factor ,
                     s.Part_D_Low_Income_Indicator ,
                     s.Part_D_Low_Income_Multiplier ,
                     s.Part_D_Long_Term_Institut_Ind ,
                     s.Part_D_Long_Term_Institut_Multi ,
                     s.Rebate_for_Part_D_Basic_Prem_Reduct ,
                     s.Part_D_Basic_Premium_Amount ,
                     s.Part_D_Direct_Subsidy_Mthly_Pay_Amt ,
                     s.Reinsurance_Subsidy_Amount ,
                     s.LIS_Cost_Sharing_Amount ,
                     s.Total_Part_D_Payment ,
                     s.Nbr_of_Paymt_Adjustmt_Mths_Part_D ,
                     s.PACE_Premium_Add_On ,
                     s.PACE_Cost_Sharing_Add_On ,
                     s.Part_C_Frailty_Score_Factor ,
                     s.MSP_Factor ,
                     s.MSP_Reduct_Adjustmt_Amt_Part_A ,
                     s.MSP_Reduct_Adjustmt_Amt_Part_B ,
                     s.Medicaid_Dual_Status_Code ,
                     s.Part_D_Coverage_Gap_Discount_Amt ,
                     s.Part_D_RA_Factor_Type ,
                     s.Default_Part_D_Risk_Factor_Code ,
                     s.Part_A_Risk_Adjstd_Mthly_Rate_Amt_for_Pymt_Adj ,
                     s.Part_B_Risk_Adjstd_Mthly_Rate_Amt_for_Pymt_Adj ,
                     s.Part_D_Direct_Subsidy_Mthly_Rate_Amt_for_Pymt_Adj ,
                     s.Cleanup_ID ,
                     s.RecordSource ,
                     @CurrentDate ,
                     @CurrentDate
                   );
    END;     




GO
