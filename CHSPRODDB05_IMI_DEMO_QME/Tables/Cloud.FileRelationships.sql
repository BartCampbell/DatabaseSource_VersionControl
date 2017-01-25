CREATE TABLE [Cloud].[FileRelationships]
(
[ChildFieldID] [int] NOT NULL,
[ParentFieldID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Cloud].[FileRelationships] ADD CONSTRAINT [PK_FileRelationships] PRIMARY KEY CLUSTERED  ([ChildFieldID], [ParentFieldID]) ON [PRIMARY]
GO
