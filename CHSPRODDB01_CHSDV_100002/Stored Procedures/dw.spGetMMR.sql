SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



---- =============================================
---- Author:		Travis Parker
---- Create date:	08/01/2016
---- Description:	Gets the latest MMR data for loading into the DW
---- Usage:			
----		  EXECUTE dw.spGetMMR '06/10/2016'
---- =============================================
CREATE PROC [dw].[spGetMMR]
    @LastLoadTime DATETIME
AS
    SET NOCOUNT ON; 

    SELECT  c.Client_BK AS CentauriClientID ,
            m.Member_BK AS CentauriMemberID ,
		  h.Sequence ,
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
		  h.MMR_BK ,
		  s.LoadDate
    FROM    dbo.S_MMRDetail s 
		  INNER JOIN dbo.H_MMR h ON h.H_MMR_RK = s.H_MMR_RK
            INNER JOIN dbo.L_Member_MMR l ON l.H_MMR_RK = s.H_MMR_RK
            INNER JOIN dbo.H_Member m ON m.H_Member_RK = l.H_Member_RK
            CROSS JOIN dbo.H_Client c
    WHERE   s.RecordEndDate IS NULL
            AND s.LoadDate > @LastLoadTime;



GO
