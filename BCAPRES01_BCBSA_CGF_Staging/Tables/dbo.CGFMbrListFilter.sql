CREATE TABLE [dbo].[CGFMbrListFilter]
(
[MemberID] [int] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [fk] ON [dbo].[CGFMbrListFilter] ([MemberID]) ON [PRIMARY]
GO
CREATE STATISTICS [sp] ON [dbo].[CGFMbrListFilter] ([MemberID])
GO
