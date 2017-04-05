CREATE TABLE [Result].[ClaimCodeSummary]
(
[ClaimMonth] [tinyint] NOT NULL,
[ClaimSrcTypeID] [tinyint] NOT NULL,
[ClaimTypeID] [tinyint] NOT NULL,
[ClaimYear] [smallint] NOT NULL,
[CodeTypeID] [tinyint] NOT NULL,
[CountClaimLines] [int] NOT NULL,
[CountCodes] [int] NOT NULL,
[CountMembers] [int] NOT NULL,
[DataRunID] [int] NOT NULL,
[DataSetID] [int] NOT NULL,
[DataSourceID] [int] NOT NULL,
[ResultRowGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_Result_ClaimCodeSummary_ResultRowGuid] DEFAULT (newid()),
[ResultRowID] [bigint] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [Result].[ClaimCodeSummary] ADD CONSTRAINT [PK_Result_ClaimCodeSummary] PRIMARY KEY CLUSTERED  ([ResultRowID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Result_ClaimCodeSummary] ON [Result].[ClaimCodeSummary] ([DataRunID], [DataSourceID], [ClaimTypeID], [ClaimSrcTypeID], [ClaimYear], [ClaimMonth], [CodeTypeID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Result_ClaimCodeSummary_ResultRowGuid] ON [Result].[ClaimCodeSummary] ([ResultRowGuid]) ON [PRIMARY]
GO
