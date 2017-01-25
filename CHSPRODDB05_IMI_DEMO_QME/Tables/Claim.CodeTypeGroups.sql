CREATE TABLE [Claim].[CodeTypeGroups]
(
[Abbrev] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CodeTypeGrpGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_CodeTypeGroups_ClaimTypeGrpGuid] DEFAULT (newid()),
[CodeTypeGrpID] [tinyint] NOT NULL,
[Descr] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Claim].[CodeTypeGroups] ADD CONSTRAINT [PK_Claim_CodeTypeGroups] PRIMARY KEY CLUSTERED  ([CodeTypeGrpID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Claim_CodeTypeGroups_Abbrev] ON [Claim].[CodeTypeGroups] ([Abbrev]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Claim_CodeTypeGroups_ClaimTypeGrpGuid] ON [Claim].[CodeTypeGroups] ([CodeTypeGrpGuid]) ON [PRIMARY]
GO
