CREATE TABLE [dbo].[WellCare_StatusReport_Master]
(
[RecID] [int] NOT NULL IDENTITY(1, 1),
[LocationID] [int] NULL,
[ProviderCnt] [int] NULL CONSTRAINT [DF__WellCare___Provi__1B220F1A] DEFAULT ((0)),
[ProviderAddressline1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderCity] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderState] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderZip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GroupName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ContactName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderPhoneNumber] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ScheduleDate] [date] NULL,
[ScheduleType] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DaysOverDue] [int] NULL CONSTRAINT [DF__WellCare___DaysO__1C163353] DEFAULT ((0)),
[TotalCharts] [int] NULL CONSTRAINT [DF__WellCare___Total__1D0A578C] DEFAULT ((0)),
[ScannedCharts] [int] NULL CONSTRAINT [DF__WellCare___Scann__1DFE7BC5] DEFAULT ((0)),
[CNACharts] [int] NULL CONSTRAINT [DF__WellCare___CNACh__1EF29FFE] DEFAULT ((0)),
[RemainingCharts] [int] NULL CONSTRAINT [DF__WellCare___Remai__1FE6C437] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WellCare_StatusReport_Master] ADD CONSTRAINT [UQ__WellCare__360414FEA6E08D48] UNIQUE NONCLUSTERED  ([RecID]) ON [PRIMARY]
GO
