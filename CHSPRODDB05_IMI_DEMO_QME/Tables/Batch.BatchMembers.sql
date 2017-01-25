CREATE TABLE [Batch].[BatchMembers]
(
[BatchID] [int] NOT NULL,
[DSMemberID] [bigint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Batch].[BatchMembers] ADD CONSTRAINT [PK_BatchMembers] PRIMARY KEY CLUSTERED  ([BatchID], [DSMemberID]) ON [PRIMARY]
GO
