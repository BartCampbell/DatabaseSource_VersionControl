CREATE TABLE [Result].[ClaimLineSummary]
(
[ClaimMonth] [tinyint] NOT NULL,
[ClaimSrcTypeID] [tinyint] NOT NULL,
[ClaimTypeID] [tinyint] NOT NULL,
[ClaimYear] [smallint] NOT NULL,
[CountClaimLines] [int] NOT NULL,
[CountMembers] [int] NOT NULL,
[DataRunID] [int] NOT NULL,
[DataSetID] [int] NOT NULL,
[DataSourceID] [int] NOT NULL,
[ResultRowGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_Result_ClaimLineSummary_ResultRowGuid] DEFAULT (newid()),
[ResultRowID] [bigint] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [Result].[ClaimLineSummary] ADD CONSTRAINT [PK_Result_ClaimLineSummary] PRIMARY KEY CLUSTERED  ([ResultRowID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Result_ClaimLineSummary] ON [Result].[ClaimLineSummary] ([DataRunID], [DataSourceID], [ClaimTypeID], [ClaimSrcTypeID], [ClaimYear], [ClaimMonth]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Result_ClaimLineSummary_ResultRowGuid] ON [Result].[ClaimLineSummary] ([ResultRowGuid]) ON [PRIMARY]
GO
