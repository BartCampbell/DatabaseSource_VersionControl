CREATE TABLE [Member].[MemberAttributes]
(
[DataSetID] [int] NOT NULL,
[DSMbrAttribID] [bigint] NOT NULL IDENTITY(1, 1),
[DSMemberID] [bigint] NOT NULL,
[MbrAttribID] [smallint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Member].[MemberAttributes] ADD CONSTRAINT [PK_MemberAttributes] PRIMARY KEY CLUSTERED  ([DSMbrAttribID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_MemberAttributes] ON [Member].[MemberAttributes] ([DSMemberID], [MbrAttribID]) ON [PRIMARY]
GO
