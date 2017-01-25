CREATE TABLE [Internal].[Claims]
(
[BatchID] [int] NOT NULL,
[BeginDate] [datetime] NOT NULL,
[ClaimTypeID] [tinyint] NOT NULL,
[DataRunID] [int] NOT NULL,
[DataSetID] [int] NOT NULL,
[DSClaimID] [bigint] NOT NULL,
[DSMemberID] [bigint] NOT NULL,
[DSProviderID] [bigint] NULL,
[EndDate] [datetime] NULL,
[LOS] [smallint] NULL,
[POS] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ServDate] [datetime] NOT NULL,
[SpId] [int] NOT NULL CONSTRAINT [DF_Claims_SpId] DEFAULT (@@spid)
) ON [PRIMARY]
GO
ALTER TABLE [Internal].[Claims] ADD CONSTRAINT [PK_Internal_Claims] PRIMARY KEY CLUSTERED  ([DSClaimID], [SpId]) ON [PRIMARY]
GO
