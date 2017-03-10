CREATE TABLE [dbo].[Member_UnsavedTestEntry]
(
[MemberID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Member_UnsavedTestEntry] ADD CONSTRAINT [PK__Member_UnsavedTe__697C9932] PRIMARY KEY CLUSTERED  ([MemberID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Member_UnsavedTestEntry] ADD CONSTRAINT [Member_UnsavedTestEntry_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[Member] ([MemberID])
GO
