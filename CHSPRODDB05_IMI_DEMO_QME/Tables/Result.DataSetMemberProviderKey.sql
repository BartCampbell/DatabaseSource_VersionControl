CREATE TABLE [Result].[DataSetMemberProviderKey]
(
[DataRunID] [int] NOT NULL,
[DataSetID] [int] NOT NULL,
[DSMemberID] [bigint] NOT NULL,
[DSProviderID] [bigint] NULL,
[MbrProvKeyID] [bigint] NOT NULL IDENTITY(1, 1),
[MedGrpID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Result].[DataSetMemberProviderKey] ADD CONSTRAINT [PK_DataSetMemberProviderKey] PRIMARY KEY CLUSTERED  ([MbrProvKeyID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_DataSetMemberProviderKey] ON [Result].[DataSetMemberProviderKey] ([DSMemberID], [DSProviderID], [MedGrpID], [DataRunID]) ON [PRIMARY]
GO
