CREATE TABLE [dbo].[tmpAetnaExtractHistoryNoClaim]
(
[MemberID] [varchar] (22) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberIndividualID] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClaimID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ServiceFromDt] [date] NULL,
[ServiceToDt] [date] NULL,
[RenProviderID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ICDCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DXCodeCategory] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ICDCodeDisposition] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ICDCodeDispositionReason] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PageFrom] [smallint] NULL,
[PageTo] [smallint] NULL,
[RenTIN] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RenPIN] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ChartName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtractDate] [datetime] NULL,
[tmpAetnaExtractHistoryNoClaimPK] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tmpAetnaExtractHistoryNoClaim] ADD CONSTRAINT [PK_tmpAetnaExtractHistoryNoClaimPK] PRIMARY KEY CLUSTERED  ([tmpAetnaExtractHistoryNoClaimPK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
