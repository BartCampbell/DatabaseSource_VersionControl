SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vwMMR]
AS
SELECT        dbo.H_MMR.CCI, dbo.S_MMRDetail.ContractNbr, dbo.S_MMRDetail.FileRunDate, dbo.S_MMRDetail.PaymentDate, dbo.S_MMRDetail.HICN, dbo.S_MMRDetail.LastName, dbo.S_MMRDetail.FirstInit, 
                         dbo.S_MMRDetail.Gender, dbo.S_MMRDetail.DOB, dbo.S_MMRDetail.StateCountyCode, dbo.S_MMRDetail.Out_Of_Area_Ind, dbo.S_MMRDetail.PartA_Entitle_Ind, dbo.S_MMRDetail.PartB_Entitle_Ind, 
                         dbo.S_MMRDetail.HospiceInd, dbo.S_MMRDetail.ESRDInd, dbo.S_MMRDetail.AgedDisabledMSPInd, dbo.S_MMRDetail.Age_Group, dbo.S_MMRDetail.InstitutionalInd, dbo.S_MMRDetail.NHCInd, 
                         dbo.S_MMRDetail.NewMedicareBenificiaryMedicaidStatus, dbo.S_MMRDetail.LTIFlg, dbo.S_MMRDetail.MedicaidInd, dbo.S_MMRDetail.PIPDCGCatg, dbo.S_MMRDetail.Default_Risk_Factor_Code, 
                         dbo.S_MMRDetail.Risk_Adjust_FactorA, dbo.S_MMRDetail.Risk_Adjust_FactorB, dbo.S_MMRDetail.Nbr_of_Pay_Adjust_Mths_Part_A, dbo.S_MMRDetail.Nbr_of_Pay_Adjust_Mths_Part_B, 
                         dbo.S_MMRDetail.Adjust_Reason_Code, dbo.S_MMRDetail.Pay_Adjust_MSA_Start_Date, dbo.S_MMRDetail.Pay_Adjust_MSA_End_Date, dbo.S_MMRDetail.Demographic_Pay_Adjust_Amt_A, 
                         dbo.S_MMRDetail.Demographic_Pay_Adjust_Amt_B, dbo.S_MMRDetail.Monthly_Pay_Adjust_Amt_A, dbo.S_MMRDetail.Monthly_Pay_Adjust_Amt_B, dbo.S_MMRDetail.LIS_Premium_Subsidy, 
                         dbo.S_MMRDetail.ESRD_MSP_Flg, dbo.S_MMRDetail.MSA_Part_A_Deposit_Recovery_Amt, dbo.S_MMRDetail.MSA_Part_B_Deposit_Recovery_Amt, dbo.S_MMRDetail.Current_Medicaid_Status, 
                         dbo.S_MMRDetail.Nbr_of_MSA_Deposit_Recovery_Mths, dbo.S_MMRDetail.Risk_Adjsuter_Age_Group, dbo.S_MMRDetail.Prevous_Disable_Ratio, dbo.S_MMRDetail.De_Minimis, 
                         dbo.S_MMRDetail.Beneficiary_Dual_Part_D_Enroll_Status_Flg, dbo.S_MMRDetail.PlanBenefitPkg_Id, dbo.S_MMRDetail.RaceInd, dbo.S_MMRDetail.RAFactorTypeCode, dbo.S_MMRDetail.FrailtyInd, 
                         dbo.S_MMRDetail.OrigReasonforEntitle_Code, dbo.S_MMRDetail.LagInd, dbo.S_MMRDetail.SegmentID, dbo.S_MMRDetail.EnrollmentSource, dbo.S_MMRDetail.EGHPFlg, 
                         dbo.S_MMRDetail.PartC_Premium_PartA_Amt, dbo.S_MMRDetail.PartC_Premium_PartB_Amt, dbo.S_MMRDetail.Rebate_PartA_Cost_Sharing_Reduct, dbo.S_MMRDetail.Rebate_PartB_Cost_Sharing_Reduct, 
                         dbo.S_MMRDetail.Rebate_Other_PartA_Mandat_Suplmt_Benefits, dbo.S_MMRDetail.Rebate_Other_PartB_Mandat_Suplmt_Benefits, dbo.S_MMRDetail.Rebate_PartB_Prem_Reduct_Part_A_Amt, 
                         dbo.S_MMRDetail.Rebate_PartB_Prem_Reduct_Part_B_Amt, dbo.S_MMRDetail.Rebate_PartD_Suplmt_Benefit_Part_A_Amt, dbo.S_MMRDetail.Rebate_PartD_Suplmt_Benefit_Part_B_Amt, 
                         dbo.S_MMRDetail.Total_PartA_MA_Payment, dbo.S_MMRDetail.Total_PartB_MA_Payment, dbo.S_MMRDetail.Total_MA_Payment_Amt, dbo.S_MMRDetail.PartD_RA_Factor, 
                         dbo.S_MMRDetail.PartD_Low_Income_Multiplier, dbo.S_MMRDetail.PartD_Low_Income_Indicator, dbo.S_MMRDetail.PartD_Long_Term_Institut_Ind, dbo.S_MMRDetail.PartD_Long_Term_Institut_Multi, 
                         dbo.S_MMRDetail.Rebate_for_PartD_Basic_Prem_Reduct, dbo.S_MMRDetail.PartD_Basic_Premium_Amount, dbo.S_MMRDetail.PartD_Direct_Subsidy_Mthly_Pay_Amt, 
                         dbo.S_MMRDetail.ReinsuranceSubsidyAmount, dbo.S_MMRDetail.LIS_CostSharingAmount, dbo.S_MMRDetail.Total_PartD_Payment, dbo.S_MMRDetail.NbrPaymtAdjustmtMthsPartD, 
                         dbo.S_MMRDetail.PACE_PremiumAddOn, dbo.S_MMRDetail.PACE_CostSharingAddOn, dbo.S_MMRDetail.PartC_FrailtyScoreFactor, dbo.S_MMRDetail.MSPFactor, 
                         dbo.S_MMRDetail.MSPReduct_Adjustmt_Amt_PartA, dbo.S_MMRDetail.MSP_Reduct_Adjustmt_Amt_PartB, dbo.S_MMRDetail.MedicaidDualStatus_Code, dbo.S_MMRDetail.PartD_Coverage_Gap_Discount_Amt, 
                         dbo.S_MMRDetail.PartD_RAFactorType, dbo.S_MMRDetail.Default_PartD_RiskFactor_Code, dbo.S_MMRDetail.PartA_Risk_Adjstd_Mthly_Rate_Amt_for_Pymt_Adj, 
                         dbo.S_MMRDetail.PartB_Risk_Adjstd_Mthly_Rate_Amt_for_Pymt_Adj, dbo.S_MMRDetail.PartD_Direct_Subsidy_Mthly_Rate_Amt_for_Pymt_Adj, dbo.S_MMRDetail.CleanupID
FROM            dbo.H_MMR INNER JOIN
                         dbo.S_MMRDetail ON dbo.H_MMR.H_MMR_RK = dbo.S_MMRDetail.H_MMR_RK
GO
EXEC sp_addextendedproperty N'MS_DiagramPane1', N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "H_MMR"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "S_MMRDetail"
            Begin Extent = 
               Top = 6
               Left = 246
               Bottom = 273
               Right = 875
            End
            DisplayFlags = 280
            TopColumn = 86
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', 'SCHEMA', N'dbo', 'VIEW', N'vwMMR', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=1
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'dbo', 'VIEW', N'vwMMR', NULL, NULL
GO
