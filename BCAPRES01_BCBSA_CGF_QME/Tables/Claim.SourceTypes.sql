CREATE TABLE [Claim].[SourceTypes]
(
[Abbrev] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[BitSeed] [tinyint] NOT NULL,
[BitValue] AS (CONVERT([bigint],power(CONVERT([bigint],(2),(0)),[BitSeed]),(0))) PERSISTED,
[ClaimSrcTypeGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_SourceTypes_ClaimSrcTypeGuid] DEFAULT (newid()),
[ClaimSrcTypeID] [tinyint] NOT NULL,
[Descr] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Claim].[SourceTypes] ADD CONSTRAINT [PK_Claim_SourceTypes] PRIMARY KEY CLUSTERED  ([ClaimSrcTypeID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Claim_SourceTypes_Abbrev] ON [Claim].[SourceTypes] ([Abbrev]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Claim_SourceTypes_ClaimSrcTypeGuid] ON [Claim].[SourceTypes] ([ClaimSrcTypeGuid]) ON [PRIMARY]
GO
