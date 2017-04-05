CREATE TABLE [Product].[BenefitRelationships]
(
[BenefitID] [smallint] NOT NULL,
[ChildID] [smallint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Product].[BenefitRelationships] ADD CONSTRAINT [PK_BenefitRelationships] PRIMARY KEY CLUSTERED  ([BenefitID], [ChildID]) ON [PRIMARY]
GO
