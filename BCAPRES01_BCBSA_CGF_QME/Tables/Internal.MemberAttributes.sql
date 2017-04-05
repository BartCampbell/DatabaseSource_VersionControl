CREATE TABLE [Internal].[MemberAttributes]
(
[BatchID] [int] NOT NULL,
[DataRunID] [int] NOT NULL,
[DataSetID] [int] NOT NULL,
[DSMbrAttribID] [bigint] NOT NULL,
[DSMemberID] [bigint] NOT NULL,
[MbrAttribID] [smallint] NOT NULL,
[SpId] [int] NOT NULL CONSTRAINT [DF_MemberAttributes_SpId] DEFAULT (@@spid)
) ON [PRIMARY]
GO
ALTER TABLE [Internal].[MemberAttributes] ADD CONSTRAINT [PK_Internal_MemberAttributes] PRIMARY KEY CLUSTERED  ([SpId], [DSMbrAttribID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Internal_MemberAttributes] ON [Internal].[MemberAttributes] ([SpId], [DSMbrAttribID], [MbrAttribID]) ON [PRIMARY]
GO
