CREATE TABLE [dbo].[WellCare_StatusReport_Master]
(
[LocationID] [int] NULL,
[ProviderCnt] [int] NULL CONSTRAINT [DF__WellCare___Provi__699FC21F] DEFAULT ((0)),
[ProviderAddressline1] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderCity] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderState] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderZip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GroupName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ContactName] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderPhoneNumber] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ScheduleDate] [date] NULL,
[ScheduleType] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DaysOverDue] [int] NULL CONSTRAINT [DF__WellCare___DaysO__6A93E658] DEFAULT ((0)),
[TotalCharts] [int] NULL CONSTRAINT [DF__WellCare___Total__6B880A91] DEFAULT ((0)),
[ScannedCharts] [int] NULL CONSTRAINT [DF__WellCare___Scann__6C7C2ECA] DEFAULT ((0)),
[CNACharts] [int] NULL CONSTRAINT [DF__WellCare___CNACh__6D705303] DEFAULT ((0)),
[RemainingCharts] [int] NULL CONSTRAINT [DF__WellCare___Remai__6E64773C] DEFAULT ((0))
) ON [PRIMARY]
GO
