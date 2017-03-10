CREATE TABLE [dbo].[Tally_Test]
(
[N] [bigint] NULL
) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [IX_Tally_Test] ON [dbo].[Tally_Test] ([N]) ON [PRIMARY]
GO
