SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jason Franks
-- Create date: 12/14/2015	
-- Description:	Updates the member_Stage_raw table with the metadata needed to load to the DataVault
-- EXAMPLE: [dbo].[prUpdateMMRStagingRaw] '100002', 'CCAI', 'P.FH3071.MONMEMD.D160201.T1725587'
-- =============================================
CREATE PROCEDURE [dbo].[prUpdateMMRStagingRaw]
	-- Add the parameters for the stored procedure here
	@ClientID varchar(32),
	@ClientName varchar(100),
	@RecordsSource varchar(200)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

--SET THE RECORDSOURCE FOR THIS DATAFILE
Update MMR_Stage set RecordSource=@RecordsSource

--SET THE CLIENTID AND CLIENT NAME FOR THIS FILE
Update MMR_Stage set CCI=@ClientID
Update MMR_Stage set ClientName=@ClientName

--GENERATE MD5 HASH for the CLIENTHASHKEY AND UPDATE IT
update MMR_Stage set ClientHashKey = upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(CCI,''))),':',
			RTRIM(LTRIM(COALESCE(ClientName,'')))
			))
			),2))



		--UPDATE LOAD DATE
		Declare @LoadDate datetime = GetDate()	
		Update MMR_STAGE set LoadDate=@LoadDate

		--Update MMR_HASH_KEY
		UPDATE MMR_STAGE SET MMR_RK_Hash=
upper(convert(char(32), HashBytes('MD5',
			Upper(Concat(
			RTRIM(LTRIM(COALESCE([SeqNum],''))),':',
				RTRIM(LTRIM(COALESCE([MCO_Contract_Nbr],''))),':',
RTRIM(LTRIM(COALESCE([File_Run_Date],''))),':',
RTRIM(LTRIM(COALESCE([Payment_YYYYMM],''))),':',
RTRIM(LTRIM(COALESCE([HICN_Nbr],''))),':',
RTRIM(LTRIM(COALESCE([Last_Name],''))),':',
RTRIM(LTRIM(COALESCE([First_Initial],''))),':',
RTRIM(LTRIM(COALESCE([Gender],''))),':',
RTRIM(LTRIM(COALESCE([Birth_Date],''))),':',
RTRIM(LTRIM(COALESCE([Age_Group],''))),':',
RTRIM(LTRIM(COALESCE([State_County_Code],''))),':',
RTRIM(LTRIM(COALESCE([Out_Of_Area_Ind],''))),':',
RTRIM(LTRIM(COALESCE([Part_A_Entitle_Ind],''))),':',
RTRIM(LTRIM(COALESCE([Part_B_Entitle_Ind],''))),':',
RTRIM(LTRIM(COALESCE([Hospice_Ind],''))),':',
RTRIM(LTRIM(COALESCE([ESRD_Ind],''))),':',
RTRIM(LTRIM(COALESCE([Aged_Disabled_MSP_Ind],''))),':',
RTRIM(LTRIM(COALESCE([Institutional_Ind],''))),':',
RTRIM(LTRIM(COALESCE([NHC_Ind],''))),':',
RTRIM(LTRIM(COALESCE([New_Medicare_Benificiary_Medicaid_Status],''))),':',
RTRIM(LTRIM(COALESCE([LTI_Flg],''))),':',
RTRIM(LTRIM(COALESCE([Medicaid_Ind],''))),':',
RTRIM(LTRIM(COALESCE([PIP_DCG_Catg],''))),':',
RTRIM(LTRIM(COALESCE([Default_Risk_Factor_Code],''))),':',
RTRIM(LTRIM(COALESCE([Risk_Adjust_Factor_A],''))),':',
RTRIM(LTRIM(COALESCE([Risk_Adjust_Factor_B],''))),':',
RTRIM(LTRIM(COALESCE([Nbr_of_Pay_Adjust_Mths_Part_A],''))),':',
RTRIM(LTRIM(COALESCE([Nbr_of_Pay_Adjust_Mths_Part_B],''))),':',
RTRIM(LTRIM(COALESCE([Adjust_Reason_Code],''))),':',
RTRIM(LTRIM(COALESCE([Pay_Adjust_MSA_Start_Date],''))),':',
RTRIM(LTRIM(COALESCE([Pay_Adjust_MSA_End_Date],''))),':',
RTRIM(LTRIM(COALESCE([Demographic_Pay_Adjust_Amt_A],''))),':',
RTRIM(LTRIM(COALESCE([Demographic_Pay_Adjust_Amt_B],''))),':',
RTRIM(LTRIM(COALESCE([Monthly_Pay_Adjust_Amt_A],''))),':',
RTRIM(LTRIM(COALESCE([Monthly_Pay_Adjust_Amt_B],''))),':',
RTRIM(LTRIM(COALESCE([LIS_Premium_Subsidy],''))),':',
RTRIM(LTRIM(COALESCE([ESRD_MSP_Flg],''))),':',
RTRIM(LTRIM(COALESCE([MSA_Part_A_Deposit_Recovery_Amt],''))),':',
RTRIM(LTRIM(COALESCE([MSA_Part_B_Deposit_Recovery_Amt],''))),':',
RTRIM(LTRIM(COALESCE([Nbr_of_MSA_Deposit_Recovery_Mths],''))),':',
RTRIM(LTRIM(COALESCE([Current_Medicaid_Status],''))),':',
RTRIM(LTRIM(COALESCE([Risk_Adjsuter_Age_Group],''))),':',
RTRIM(LTRIM(COALESCE([Prevous_Disable_Ratio],''))),':',
RTRIM(LTRIM(COALESCE([De_Minimis],''))),':',
RTRIM(LTRIM(COALESCE([Beneficiary_Dual_Part_D_Enroll_Status_Flg],''))),':',
RTRIM(LTRIM(COALESCE([Plan_Benefit_Pkg_Id],''))),':',
RTRIM(LTRIM(COALESCE([Race_Ind],''))),':',
RTRIM(LTRIM(COALESCE([RA_Factor_Type_Code],''))),':',
RTRIM(LTRIM(COALESCE([Frailty_Ind],''))),':',
RTRIM(LTRIM(COALESCE([Orig_Reason_for_Entitle_Code],''))),':',
RTRIM(LTRIM(COALESCE([Lag_Ind],''))),':',
RTRIM(LTRIM(COALESCE([Segment_ID],''))),':',
RTRIM(LTRIM(COALESCE([Enrollment_Source],''))),':',
RTRIM(LTRIM(COALESCE([EGHP_Flg],''))),':',
RTRIM(LTRIM(COALESCE([Part_C_Premium_Part_A_Amt],''))),':',
RTRIM(LTRIM(COALESCE([Part_C_Premium_Part_B_Amt],''))),':',
RTRIM(LTRIM(COALESCE([Rebate_Part_A_Cost_Sharing_Reduct],''))),':',
RTRIM(LTRIM(COALESCE([Rebate_Part_B_Cost_Sharing_Reduct],''))),':',
RTRIM(LTRIM(COALESCE([Rebate_Other_Part_A_Mandat_Suplmt_Benefits],''))),':',
RTRIM(LTRIM(COALESCE([Rebate_Other_Part_B_Mandat_Suplmt_Benefits],''))),':',
RTRIM(LTRIM(COALESCE([Rebate_Part_B_Prem_Reduct_Part_A_Amt],''))),':',
RTRIM(LTRIM(COALESCE([Rebate_Part_B_Prem_Reduct_Part_B_Amt],''))),':',
RTRIM(LTRIM(COALESCE([Rebate_Part_D_Suplmt_Benefit_Part_A_Amt],''))),':',
RTRIM(LTRIM(COALESCE([Rebate_Part_D_Suplmt_Benefit_Part_B_Amt],''))),':',
RTRIM(LTRIM(COALESCE([Total_Part_A_MA_Payment],''))),':',
RTRIM(LTRIM(COALESCE([Total_Part_B_MA_Payment],''))),':',
RTRIM(LTRIM(COALESCE([Total_MA_Payment_Amt],''))),':',
RTRIM(LTRIM(COALESCE([Part_D_RA_Factor],''))),':',
RTRIM(LTRIM(COALESCE([Part_D_Low_Income_Indicator],''))),':',
RTRIM(LTRIM(COALESCE([Part_D_Low_Income_Multiplier],''))),':',
RTRIM(LTRIM(COALESCE([Part_D_Long_Term_Institut_Ind],''))),':',
RTRIM(LTRIM(COALESCE([Part_D_Long_Term_Institut_Multi],''))),':',
RTRIM(LTRIM(COALESCE([Rebate_for_Part_D_Basic_Prem_Reduct],''))),':',
RTRIM(LTRIM(COALESCE([Part_D_Basic_Premium_Amount],''))),':',
RTRIM(LTRIM(COALESCE([Part_D_Direct_Subsidy_Mthly_Pay_Amt],''))),':',
RTRIM(LTRIM(COALESCE([Reinsurance_Subsidy_Amount],''))),':',
RTRIM(LTRIM(COALESCE([LIS_Cost_Sharing_Amount],''))),':',
RTRIM(LTRIM(COALESCE([Total_Part_D_Payment],''))),':',
RTRIM(LTRIM(COALESCE([Nbr_of_Paymt_Adjustmt_Mths_Part_D],''))),':',
RTRIM(LTRIM(COALESCE([PACE_Premium_Add_On],''))),':',
RTRIM(LTRIM(COALESCE([PACE_Cost_Sharing_Add_On],''))),':',
RTRIM(LTRIM(COALESCE([Part_C_Frailty_Score_Factor],''))),':',
RTRIM(LTRIM(COALESCE([MSP_Factor],''))),':',
RTRIM(LTRIM(COALESCE([MSP_Reduct_Adjustmt_Amt_Part_A],''))),':',
RTRIM(LTRIM(COALESCE([MSP_Reduct_Adjustmt_Amt_Part_B],''))),':',
RTRIM(LTRIM(COALESCE([Medicaid_Dual_Status_Code],''))),':',
RTRIM(LTRIM(COALESCE([Part_D_Coverage_Gap_Discount_Amt],''))),':',
RTRIM(LTRIM(COALESCE([Part_D_RA_Factor_Type],''))),':',
RTRIM(LTRIM(COALESCE([Default_Part_D_Risk_Factor_Code],''))),':',
RTRIM(LTRIM(COALESCE([Part_A_Risk_Adjstd_Mthly_Rate_Amt_for_Pymt_Adj],''))),':',
RTRIM(LTRIM(COALESCE([Part_B_Risk_Adjstd_Mthly_Rate_Amt_for_Pymt_Adj],''))),':',
RTRIM(LTRIM(COALESCE([Part_D_Direct_Subsidy_Mthly_Rate_Amt_for_Pymt_Adj],''))),':',
RTRIM(LTRIM(COALESCE([Cleanup_ID],''))))
			)),2))

			---SET SEQNUM for MMR_HASH_KEY Sets
			;WITH SeqCTE(RowNum,MMR_RK_Hash, SeqNum)
			AS
			(
				SELECT
				   RecNum,
					MMR_RK_Hash,
					ROW_NUMBER() OVER (PARTITION BY MMR_RK_Hash ORDER BY MMR_RK_Hash)  As SeqNum
				 FROM MMR_STAGE
			 )
			 UPDATE a
			 SET a.SeqNum = b.SeqNum
			 FROM MMR_Stage a
			 INNER JOIN SeqCTE b ON b.rownum = a.RecNum;

	--UPDATE RECORD SOURCE WITH JUST THE FILE NAME
	UPDATE MMR_Stage SET RecordSource = SUBSTRING(RecordSource,dbo.GetLastCharIndex(RecordSource,'\')+1,100)
END


GO
