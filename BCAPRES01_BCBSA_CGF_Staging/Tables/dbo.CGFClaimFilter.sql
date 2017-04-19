CREATE TABLE [dbo].[CGFClaimFilter]
(
[ClaimID] [int] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [fk] ON [dbo].[CGFClaimFilter] ([ClaimID]) ON [PRIMARY]
GO
CREATE STATISTICS [sp] ON [dbo].[CGFClaimFilter] ([ClaimID])
GO
