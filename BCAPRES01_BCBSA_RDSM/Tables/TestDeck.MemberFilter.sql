CREATE TABLE [TestDeck].[MemberFilter]
(
[MemberID] [int] NULL,
[RowID] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [fk] ON [TestDeck].[MemberFilter] ([MemberID]) ON [PRIMARY]
GO
CREATE STATISTICS [sp] ON [TestDeck].[MemberFilter] ([MemberID])
GO
