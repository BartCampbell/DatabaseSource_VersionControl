CREATE TABLE [Internal].[ClaimAttributes]
(
[BatchID] [int] NOT NULL,
[ClaimAttribID] [int] NOT NULL,
[DataRunID] [int] NOT NULL,
[DataSetID] [int] NOT NULL,
[DSClaimAttribID] [bigint] NOT NULL,
[DSClaimLineID] [bigint] NOT NULL,
[DSMemberID] [bigint] NOT NULL,
[SpId] [int] NOT NULL CONSTRAINT [DF_ClaimAttributes_SpId] DEFAULT (@@spid)
) ON [PRIMARY]
GO
ALTER TABLE [Internal].[ClaimAttributes] ADD CONSTRAINT [PK_Internal_ClaimAttributes] PRIMARY KEY CLUSTERED  ([DSClaimAttribID], [SpId]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Internal_ClaimAttributes_DSClaimLineID] ON [Internal].[ClaimAttributes] ([DSClaimLineID], [ClaimAttribID], [SpId]) ON [PRIMARY]
GO
