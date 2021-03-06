SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jason Franks
-- Create date:	1/27/2016
-- Description:	Data Vault MMR Load
-- =============================================
CREATE PROCEDURE [dbo].[prDV_MMR_LoadSats]
	-- Add the parameters for the stored procedure here
AS
    BEGIN

        SET NOCOUNT ON;

	   --LOAD MemberHICN A RECORDS
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
                        m.LoadDate ,
                        m.H_Member_RK ,
                        m.HICN_Nbr ,
                        m.S_MemberHICN_HashDiff ,
                        m.RecordSource
                FROM    CHSStaging.mmr.MMR_Stage m
                        LEFT JOIN dbo.S_MemberHICN s ON s.H_Member_RK = m.H_Member_RK
                                                        AND s.RecordEndDate IS NULL
                                                        AND s.HashDiff = m.S_MemberHICN_HashDiff
                WHERE   s.S_MemberHICN_RK IS NULL;

	   --RECORD END DATE CLEANUP
        UPDATE  dbo.S_MemberHICN
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                                    FROM      dbo.S_MemberHICN AS z
                                    WHERE     z.H_Member_RK = a.H_Member_RK
                                            AND z.LoadDate > a.LoadDate
                                )
        FROM    dbo.S_MemberHICN a
        WHERE   a.RecordEndDate IS NULL;

	   --LOAD MMR Detail
        INSERT  INTO dbo.S_MMRDetail
                ( [S_MMRDetail_RK] ,
                  [H_MMR_RK] ,
                  [MCO_Contract_Nbr] ,
                  [File_Run_Date] ,
                  [Payment_YYYYMM] ,
                  [HICN_Nbr] ,
                  [Last_Name] ,
                  [First_Initial] ,
                  [Gender] ,
                  [Birth_Date] ,
                  [Age_Group] ,
                  [State_County_Code] ,
                  [Out_Of_Area_Ind] ,
                  [Part_A_Entitle_Ind] ,
                  [Part_B_Entitle_Ind] ,
                  [Hospice_Ind] ,
                  [ESRD_Ind] ,
                  [Aged_Disabled_MSP_Ind] ,
                  [Institutional_Ind] ,
                  [NHC_Ind] ,
                  [New_Medicare_Benificiary_Medicaid_Status] ,
                  [LTI_Flg] ,
                  [Medicaid_Ind] ,
                  [PIP_DCG_Catg] ,
                  [Default_Risk_Factor_Code] ,
                  [Risk_Adjust_Factor_A] ,
                  [Risk_Adjust_Factor_B] ,
                  [Nbr_of_Pay_Adjust_Mths_Part_A] ,
                  [Nbr_of_Pay_Adjust_Mths_Part_B] ,
                  [Adjust_Reason_Code] ,
                  [Pay_Adjust_MSA_Start_Date] ,
                  [Pay_Adjust_MSA_End_Date] ,
                  [Demographic_Pay_Adjust_Amt_A] ,
                  [Demographic_Pay_Adjust_Amt_B] ,
                  [Monthly_Pay_Adjust_Amt_A] ,
                  [Monthly_Pay_Adjust_Amt_B] ,
                  [LIS_Premium_Subsidy] ,
                  [ESRD_MSP_Flg] ,
                  [MSA_Part_A_Deposit_Recovery_Amt] ,
                  [MSA_Part_B_Deposit_Recovery_Amt] ,
                  [Nbr_of_MSA_Deposit_Recovery_Mths] ,
                  [Current_Medicaid_Status] ,
                  [Risk_Adjuster_Age_Group] ,
                  [Previous_Disable_Ratio] ,
                  [De_Minimis] ,
                  [Beneficiary_Dual_Part_D_Enroll_Status_Flg] ,
                  [Plan_Benefit_Pkg_Id] ,
                  [Race_Ind] ,
                  [RA_Factor_Type_Code] ,
                  [Frailty_Ind] ,
                  [Orig_Reason_for_Entitle_Code] ,
                  [Lag_Ind] ,
                  [Segment_ID] ,
                  [Enrollment_Source] ,
                  [EGHP_Flg] ,
                  [Part_C_Premium_Part_A_Amt] ,
                  [Part_C_Premium_Part_B_Amt] ,
                  [Rebate_Part_A_Cost_Sharing_Reduct] ,
                  [Rebate_Part_B_Cost_Sharing_Reduct] ,
                  [Rebate_Other_Part_A_Mandat_Suplmt_Benefits] ,
                  [Rebate_Other_Part_B_Mandat_Suplmt_Benefits] ,
                  [Rebate_Part_B_Prem_Reduct_Part_A_Amt] ,
                  [Rebate_Part_B_Prem_Reduct_Part_B_Amt] ,
                  [Rebate_Part_D_Suplmt_Benefit_Part_A_Amt] ,
                  [Rebate_Part_D_Suplmt_Benefit_Part_B_Amt] ,
                  [Total_Part_A_MA_Payment] ,
                  [Total_Part_B_MA_Payment] ,
                  [Total_MA_Payment_Amt] ,
                  [Part_D_RA_Factor] ,
                  [Part_D_Low_Income_Indicator] ,
                  [Part_D_Low_Income_Multiplier] ,
                  [Part_D_Long_Term_Institut_Ind] ,
                  [Part_D_Long_Term_Institut_Multi] ,
                  [Rebate_for_Part_D_Basic_Prem_Reduct] ,
                  [Part_D_Basic_Premium_Amount] ,
                  [Part_D_Direct_Subsidy_Mthly_Pay_Amt] ,
                  [Reinsurance_Subsidy_Amount] ,
                  [LIS_Cost_Sharing_Amount] ,
                  [Total_Part_D_Payment] ,
                  [Nbr_of_Paymt_Adjustmt_Mths_Part_D] ,
                  [PACE_Premium_Add_On] ,
                  [PACE_Cost_Sharing_Add_On] ,
                  [Part_C_Frailty_Score_Factor] ,
                  [MSP_Factor] ,
                  [MSP_Reduct_Adjustmt_Amt_Part_A] ,
                  [MSP_Reduct_Adjustmt_Amt_Part_B] ,
                  [Medicaid_Dual_Status_Code] ,
                  [Part_D_Coverage_Gap_Discount_Amt] ,
                  [Part_D_RA_Factor_Type] ,
                  [Default_Part_D_Risk_Factor_Code] ,
                  [Part_A_Risk_Adjstd_Mthly_Rate_Amt_for_Pymt_Adj] ,
                  [Part_B_Risk_Adjstd_Mthly_Rate_Amt_for_Pymt_Adj] ,
                  [Part_D_Direct_Subsidy_Mthly_Rate_Amt_for_Pymt_Adj] ,
                  [Cleanup_ID] ,
                  [HashDiff] ,
                  [LoadDate] ,
                  [RecordSource]
		      )
                SELECT  m.S_MMRDetail_RK ,
                        m.H_MMR_RK ,
                        m.MCO_Contract_Nbr ,
                        m.File_Run_Date ,
                        m.Payment_YYYYMM ,
                        m.HICN_Nbr ,
                        m.Last_Name ,
                        m.First_Initial ,
                        m.Gender ,
                        m.Birth_Date ,
                        m.Age_Group ,
                        m.State_County_Code ,
                        m.Out_Of_Area_Ind ,
                        m.Part_A_Entitle_Ind ,
                        m.Part_B_Entitle_Ind ,
                        m.Hospice_Ind ,
                        m.ESRD_Ind ,
                        m.Aged_Disabled_MSP_Ind ,
                        m.Institutional_Ind ,
                        m.NHC_Ind ,
                        m.New_Medicare_Benificiary_Medicaid_Status ,
                        m.LTI_Flg ,
                        m.Medicaid_Ind ,
                        m.PIP_DCG_Catg ,
                        m.Default_Risk_Factor_Code ,
                        m.Risk_Adjust_Factor_A ,
                        m.Risk_Adjust_Factor_B ,
                        m.Nbr_of_Pay_Adjust_Mths_Part_A ,
                        m.Nbr_of_Pay_Adjust_Mths_Part_B ,
                        m.Adjust_Reason_Code ,
                        m.Pay_Adjust_MSA_Start_Date ,
                        m.Pay_Adjust_MSA_End_Date ,
                        m.Demographic_Pay_Adjust_Amt_A ,
                        m.Demographic_Pay_Adjust_Amt_B ,
                        m.Monthly_Pay_Adjust_Amt_A ,
                        m.Monthly_Pay_Adjust_Amt_B ,
                        m.LIS_Premium_Subsidy ,
                        m.ESRD_MSP_Flg ,
                        m.MSA_Part_A_Deposit_Recovery_Amt ,
                        m.MSA_Part_B_Deposit_Recovery_Amt ,
                        m.Nbr_of_MSA_Deposit_Recovery_Mths ,
                        m.Current_Medicaid_Status ,
                        m.Risk_Adjuster_Age_Group ,
                        m.Previous_Disable_Ratio ,
                        m.De_Minimis ,
                        m.Beneficiary_Dual_Part_D_Enroll_Status_Flg ,
                        m.Plan_Benefit_Pkg_Id ,
                        m.Race_Ind ,
                        m.RA_Factor_Type_Code ,
                        m.Frailty_Ind ,
                        m.Orig_Reason_for_Entitle_Code ,
                        m.Lag_Ind ,
                        m.Segment_ID ,
                        m.Enrollment_Source ,
                        m.EGHP_Flg ,
                        m.Part_C_Premium_Part_A_Amt ,
                        m.Part_C_Premium_Part_B_Amt ,
                        m.Rebate_Part_A_Cost_Sharing_Reduct ,
                        m.Rebate_Part_B_Cost_Sharing_Reduct ,
                        m.Rebate_Other_Part_A_Mandat_Suplmt_Benefits ,
                        m.Rebate_Other_Part_B_Mandat_Suplmt_Benefits ,
                        m.Rebate_Part_B_Prem_Reduct_Part_A_Amt ,
                        m.Rebate_Part_B_Prem_Reduct_Part_B_Amt ,
                        m.Rebate_Part_D_Suplmt_Benefit_Part_A_Amt ,
                        m.Rebate_Part_D_Suplmt_Benefit_Part_B_Amt ,
                        m.Total_Part_A_MA_Payment ,
                        m.Total_Part_B_MA_Payment ,
                        m.Total_MA_Payment_Amt ,
                        m.Part_D_RA_Factor ,
                        m.Part_D_Low_Income_Indicator ,
                        m.Part_D_Low_Income_Multiplier ,
                        m.Part_D_Long_Term_Institut_Ind ,
                        m.Part_D_Long_Term_Institut_Multi ,
                        m.Rebate_for_Part_D_Basic_Prem_Reduct ,
                        m.Part_D_Basic_Premium_Amount ,
                        m.Part_D_Direct_Subsidy_Mthly_Pay_Amt ,
                        m.Reinsurance_Subsidy_Amount ,
                        m.LIS_Cost_Sharing_Amount ,
                        m.Total_Part_D_Payment ,
                        m.Nbr_of_Paymt_Adjustmt_Mths_Part_D ,
                        m.PACE_Premium_Add_On ,
                        m.PACE_Cost_Sharing_Add_On ,
                        m.Part_C_Frailty_Score_Factor ,
                        m.MSP_Factor ,
                        m.MSP_Reduct_Adjustmt_Amt_Part_A ,
                        m.MSP_Reduct_Adjustmt_Amt_Part_B ,
                        m.Medicaid_Dual_Status_Code ,
                        m.Part_D_Coverage_Gap_Discount_Amt ,
                        m.Part_D_RA_Factor_Type ,
                        m.Default_Part_D_Risk_Factor_Code ,
                        m.Part_A_Risk_Adjstd_Mthly_Rate_Amt_for_Pymt_Adj ,
                        m.Part_B_Risk_Adjstd_Mthly_Rate_Amt_for_Pymt_Adj ,
                        m.Part_D_Direct_Subsidy_Mthly_Rate_Amt_for_Pymt_Adj ,
                        m.Cleanup_ID ,
                        m.S_MMRDetail_HashDiff ,
                        m.LoadDate ,
                        m.RecordSource 
                FROM    CHSStaging.mmr.MMR_Stage m
                        LEFT JOIN dbo.S_MMRDetail s ON m.H_MMR_RK = s.H_MMR_RK
                                                       AND s.RecordEndDate IS NULL
                                                       AND m.S_MMRDetail_HashDiff = s.HashDiff
                WHERE   s.S_MMRDetail_RK IS NULL; 

	   --RECORD END DATE CLEANUP
        UPDATE  dbo.S_MMRDetail
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                                    FROM      dbo.S_MMRDetail AS z
                                    WHERE     z.H_MMR_RK = a.H_MMR_RK
                                            AND z.LoadDate > a.LoadDate
                                )
        FROM    dbo.S_MMRDetail a
        WHERE   a.RecordEndDate IS NULL;

    END;

    
GO
