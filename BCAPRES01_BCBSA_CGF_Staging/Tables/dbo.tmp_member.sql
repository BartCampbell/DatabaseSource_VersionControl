CREATE TABLE [dbo].[tmp_member]
(
[MemberID] [int] NULL,
[ihds_member_id] [int] NULL
) ON [Tmp_Drive04]
GO
CREATE NONCLUSTERED INDEX [idx] ON [dbo].[tmp_member] ([ihds_member_id], [MemberID]) ON [Tmp_Drive04]
GO
CREATE STATISTICS [spidx] ON [dbo].[tmp_member] ([ihds_member_id], [MemberID])
GO
