CREATE TABLE [Claim].[CodeTypes]
(
[Abbrev] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CodeType] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CodeTypeGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_CodeTypes_CodeTypeGuid] DEFAULT (newid()),
[CodeTypeID] [tinyint] NOT NULL,
[Descr] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ValidLike] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CodeTypes_ValidLike] DEFAULT ('%'),
[ValidMaxLength] [tinyint] NOT NULL CONSTRAINT [DF_CodeTypes_ValidMaxLength] DEFAULT ((16)),
[ValidMinLength] [tinyint] NOT NULL CONSTRAINT [DF_CodeTypes_ValidMinLength] DEFAULT ((1))
) ON [PRIMARY]
GO
ALTER TABLE [Claim].[CodeTypes] ADD CONSTRAINT [CK_Claim_CodeTypes_ValidMaxLength] CHECK (([ValidMaxLength]<=(16) OR [ValidMaxLength] IS NULL))
GO
ALTER TABLE [Claim].[CodeTypes] ADD CONSTRAINT [CK_Claim_CodeTypes_ValidMinLength] CHECK (([ValidMinLength]>=(1) OR [ValidMinLength] IS NULL))
GO
ALTER TABLE [Claim].[CodeTypes] ADD CONSTRAINT [PK_CodeTypes] PRIMARY KEY CLUSTERED  ([CodeTypeID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_CodeTypes_Abbrev] ON [Claim].[CodeTypes] ([Abbrev]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_CodeTypes_CodeType] ON [Claim].[CodeTypes] ([CodeType]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_CodeTypes_CodeTypeGuid] ON [Claim].[CodeTypes] ([CodeTypeGuid]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_CodeTypes_Descr] ON [Claim].[CodeTypes] ([Descr]) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Maximum length must be less than or equal to 16.', 'SCHEMA', N'Claim', 'TABLE', N'CodeTypes', 'CONSTRAINT', N'CK_Claim_CodeTypes_ValidMaxLength'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Minimum Length must be greater than or equal to 1.', 'SCHEMA', N'Claim', 'TABLE', N'CodeTypes', 'CONSTRAINT', N'CK_Claim_CodeTypes_ValidMinLength'
GO
