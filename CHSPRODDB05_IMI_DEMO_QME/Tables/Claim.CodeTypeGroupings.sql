CREATE TABLE [Claim].[CodeTypeGroupings]
(
[CodeTypeGrpID] [tinyint] NOT NULL,
[CodeTypeID] [tinyint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Claim].[CodeTypeGroupings] ADD CONSTRAINT [PK_Claim_CodeTypeGroupings] PRIMARY KEY CLUSTERED  ([CodeTypeGrpID], [CodeTypeID]) ON [PRIMARY]
GO
