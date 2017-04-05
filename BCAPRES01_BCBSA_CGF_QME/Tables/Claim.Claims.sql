CREATE TABLE [Claim].[Claims]
(
[BeginDate] [datetime] NOT NULL,
[ClaimTypeID] [tinyint] NOT NULL,
[DataSetID] [int] NOT NULL,
[DSClaimID] [bigint] NOT NULL,
[DSMemberID] [bigint] NOT NULL,
[DSProviderID] [bigint] NULL,
[EndDate] [datetime] NULL,
[LOS] [smallint] NULL,
[POS] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ServDate] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Claim].[Claims] ADD CONSTRAINT [PK_Claims] PRIMARY KEY CLUSTERED  ([DSClaimID]) ON [PRIMARY]
GO
