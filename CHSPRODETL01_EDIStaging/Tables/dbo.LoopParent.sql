CREATE TABLE [dbo].[LoopParent]
(
[LoopID] [int] NOT NULL,
[ParentLoopID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LoopParent] ADD CONSTRAINT [PK_LoopParent] PRIMARY KEY CLUSTERED  ([LoopID]) ON [PRIMARY]
GO
