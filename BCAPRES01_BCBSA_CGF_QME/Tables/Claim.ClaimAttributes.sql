CREATE TABLE [Claim].[ClaimAttributes]
(
[ClaimAttribID] [int] NOT NULL,
[DataSetID] [int] NOT NULL,
[DSClaimAttribID] [bigint] NOT NULL,
[DSClaimLineID] [bigint] NOT NULL,
[DSMemberID] [bigint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Claim].[ClaimAttributes] ADD CONSTRAINT [PK_ClaimAttributes] PRIMARY KEY CLUSTERED  ([DSClaimAttribID], [DataSetID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_ClaimAttributes_DSClaimLineID] ON [Claim].[ClaimAttributes] ([DSClaimLineID], [ClaimAttribID], [DataSetID]) ON [PRIMARY]
GO
