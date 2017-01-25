CREATE TABLE [Result].[SystematicSamples]
(
[DataRunID] [int] NOT NULL,
[DataSetID] [int] NOT NULL,
[DSMemberID] [bigint] NOT NULL,
[IsAuxiliary] [bit] NOT NULL,
[KeyDate] [datetime] NOT NULL,
[ResultRowGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_SystematicSamples_ResultRowGuid] DEFAULT (newid()),
[ResultRowID] [bigint] NOT NULL IDENTITY(1, 1),
[SysSampleID] [int] NOT NULL,
[SysSampleOrder] [int] NOT NULL,
[SysSampleRefGuid] AS ([ResultRowGuid]) PERSISTED NOT NULL,
[SysSampleRefID] AS ([ResultRowID]) PERSISTED NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Result].[SystematicSamples] ADD CONSTRAINT [PK_Result_SystematicSamples] PRIMARY KEY CLUSTERED  ([ResultRowID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Result_SystematicSamples_SysSampleRefGuid] ON [Result].[SystematicSamples] ([SysSampleRefGuid]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Result_SystematicSamples] ON [Result].[SystematicSamples] ([SysSampleRefID]) ON [PRIMARY]
GO
