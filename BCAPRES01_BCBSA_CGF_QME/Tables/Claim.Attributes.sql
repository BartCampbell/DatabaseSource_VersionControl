CREATE TABLE [Claim].[Attributes]
(
[Abbrev] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[BitSeed] [tinyint] NULL,
[BitValue] AS (CONVERT([bigint],power(CONVERT([bigint],(2),(0)),[BitSeed]),(0))) PERSISTED,
[ClaimAttribGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_Attributes_ClaimAttribGuid] DEFAULT (newid()),
[ClaimAttribID] [smallint] NOT NULL,
[ClaimTypeID] [tinyint] NOT NULL,
[Descr] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Claim].[Attributes] ADD CONSTRAINT [CK_Claim_Attributes_BitSeed] CHECK (([BitSeed] IS NULL OR [BitSeed]>=(0) AND [BitSeed]<=(62)))
GO
ALTER TABLE [Claim].[Attributes] ADD CONSTRAINT [PK_Claim_Attributes] PRIMARY KEY CLUSTERED  ([ClaimAttribID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Claim_Attributes_Abbrev] ON [Claim].[Attributes] ([Abbrev]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Claim_Attributes_BitSeed] ON [Claim].[Attributes] ([BitSeed]) WHERE ([BitSeed] IS NOT NULL) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Claim_Attributes_ClaimAttribGuid] ON [Claim].[Attributes] ([ClaimAttribGuid]) ON [PRIMARY]
GO
