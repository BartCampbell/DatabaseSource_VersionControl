CREATE TABLE [dbo].[ExecutiveDashboard_ChaseSummary]
(
[RecID] [int] NOT NULL IDENTITY(1, 1),
[ClientID] [int] NULL,
[ProjectID] [int] NULL,
[TotalChaseCount] [int] NULL CONSTRAINT [DF__Executive__Total__50C9275D] DEFAULT ((0)),
[TotalCNA] [int] NULL CONSTRAINT [DF__Executive__Total__51BD4B96] DEFAULT ((0)),
[TotalAdjustedCount] [int] NULL CONSTRAINT [DF__Executive__Total__52B16FCF] DEFAULT ((0)),
[TotalGoalCount] [int] NULL CONSTRAINT [DF__Executive__Total__53A59408] DEFAULT ((0)),
[TotalScheduledCount] [int] NULL CONSTRAINT [DF__Executive__Total__5499B841] DEFAULT ((0)),
[TotalOnSite] [int] NULL CONSTRAINT [DF__Executive__Total__558DDC7A] DEFAULT ((0)),
[TotalFaxIn] [int] NULL CONSTRAINT [DF__Executive__Total__568200B3] DEFAULT ((0)),
[TotalEMR] [int] NULL CONSTRAINT [DF__Executive__Total__577624EC] DEFAULT ((0)),
[TotalMail] [int] NULL CONSTRAINT [DF__Executive__Total__586A4925] DEFAULT ((0)),
[TotalEmail] [int] NULL CONSTRAINT [DF__Executive__Total__595E6D5E] DEFAULT ((0)),
[TotalInvoice] [int] NULL CONSTRAINT [DF__Executive__Total__5A529197] DEFAULT ((0)),
[TotalExtracted] [int] NULL CONSTRAINT [DF__Executive__Total__5B46B5D0] DEFAULT ((0)),
[MilestoneCount] [int] NULL CONSTRAINT [DF__Executive__Miles__5C3ADA09] DEFAULT ((0)),
[VarianceCount] [int] NULL CONSTRAINT [DF__Executive__Varia__5D2EFE42] DEFAULT ((0)),
[Inventory_RecordsScheduled] [int] NULL CONSTRAINT [DF__Executive__Inven__5E23227B] DEFAULT ((0)),
[Inventory_RemainingtoProcess] [int] NULL CONSTRAINT [DF__Executive__Inven__5F1746B4] DEFAULT ((0)),
[TotalCharts_Top25LocationsOffices_Scheduled] [int] NULL CONSTRAINT [DF__Executive__Total__600B6AED] DEFAULT ((0)),
[LoadDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ExecutiveDashboard_ChaseSummary] ADD CONSTRAINT [UQ__Executiv__360414FE6155451C] UNIQUE NONCLUSTERED  ([RecID]) ON [PRIMARY]
GO
