CREATE TABLE [dbo].[WellCare_MasterChaseListAudit]
(
[RecID] [bigint] NOT NULL IDENTITY(1, 1),
[OfficePK] [int] NULL,
[ProviderAddress] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderCity] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderState] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderZip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TotalChases] [int] NULL CONSTRAINT [DF__WellCare___Total__45777042] DEFAULT ((0)),
[TotalCNA] [int] NULL CONSTRAINT [DF__WellCare___Total__466B947B] DEFAULT ((0)),
[TotalScanned] [int] NULL CONSTRAINT [DF__WellCare___Total__475FB8B4] DEFAULT ((0)),
[TotalRemaining] [int] NULL CONSTRAINT [DF__WellCare___Total__4853DCED] DEFAULT ((0)),
[OfficeScheduled] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OfficeFutureScheduled] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OfficeIssue] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OfficeNotContacted] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WellCare_MasterChaseListAudit] ADD CONSTRAINT [UQ__WellCare__360414FE1D4D4C12] UNIQUE NONCLUSTERED  ([RecID]) ON [PRIMARY]
GO
