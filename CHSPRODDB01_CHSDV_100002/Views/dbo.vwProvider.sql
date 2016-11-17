SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vwProvider]
AS
SELECT        TOP (100) PERCENT hub.NPI, provloc.NetworkID, provloc.NetworkName, provsat.LastName, provsat.FirstName, provloc.Address1, provloc.Address2, provloc.City, provloc.County, provloc.State, provloc.ZipCode, 
                         provtype.ProviderTypeCode, provtype.ProviderTypeDesc, provspec.SpecialtyDesc, provspec.SpecialtyCode, provloc.Fax, provloc.Phone, hub.LoadDate, hub.RecordSource, dbo.L_CHSClientProvider.CHSClientID, 
                         dbo.H_CHSClient.ClientName
FROM            dbo.H_Provider AS hub INNER JOIN
                         dbo.S_Provider AS provsat ON provsat.ProviderID = hub.ProviderID INNER JOIN
                         dbo.S_ProviderLocation AS provloc ON provloc.ProviderID = hub.ProviderID INNER JOIN
                         dbo.S_ProviderType AS provtype ON provtype.ProviderID = hub.ProviderID INNER JOIN
                         dbo.S_ProviderSpecialty AS provspec ON provspec.ProviderID = hub.ProviderID INNER JOIN
                         dbo.L_CHSClientProvider ON hub.ProviderID = dbo.L_CHSClientProvider.ProviderID INNER JOIN
                         dbo.H_CHSClient ON dbo.L_CHSClientProvider.CHSClientID = dbo.H_CHSClient.CHSClientID
GROUP BY hub.NPI, provloc.NetworkID, provloc.NetworkName, provsat.LastName, provsat.FirstName, provloc.Address1, provloc.Address2, provloc.City, provloc.County, provloc.State, provloc.ZipCode, 
                         provtype.ProviderTypeCode, provtype.ProviderTypeDesc, provspec.SpecialtyDesc, provspec.SpecialtyCode, provloc.Fax, provloc.Phone, hub.LoadDate, hub.RecordSource, dbo.L_CHSClientProvider.CHSClientID, 
                         dbo.H_CHSClient.ClientName
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
         Begin Table = "hub"
            Begin Extent = 
               Top = 22
               Left = 669
               Bottom = 152
               Right = 839
            End
            DisplayFlags = 280
            TopColumn = 2
         End
         Begin Table = "provsat"
            Begin Extent = 
               Top = 6
               Left = 246
               Bottom = 136
               Right = 416
            End
            DisplayFlags = 280
            TopColumn = 3
         End
         Begin Table = "provloc"
            Begin Extent = 
               Top = 6
               Left = 454
               Bottom = 136
               Right = 624
            End
            DisplayFlags = 280
            TopColumn = 11
         End
         Begin Table = "provtype"
            Begin Extent = 
               Top = 174
               Left = 668
               Bottom = 304
               Right = 862
            End
            DisplayFlags = 280
            TopColumn = 3
         End
         Begin Table = "provspec"
            Begin Extent = 
               Top = 167
               Left = 209
               Bottom = 297
               Right = 424
            End
            DisplayFlags = 280
            TopColumn = 3
         End
         Begin Table = "L_CHSClientProvider"
            Begin Extent = 
               Top = 6
               Left = 877
               Bottom = 136
               Right = 1099
            End
            DisplayFlags = 280
            TopColumn = 2
         End
         Begin Table = "H_CHSClient"
            Begin Extent = 
               Top = 151
               Left = 1069
               Bottom = 281
               Right = 1239
            End
            D', 'SCHEMA', N'dbo', 'VIEW', N'vwProvider', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_DiagramPane2', N'isplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 15
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
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
', 'SCHEMA', N'dbo', 'VIEW', N'vwProvider', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=2
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'dbo', 'VIEW', N'vwProvider', NULL, NULL
GO
