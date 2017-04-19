CREATE TABLE [dbo].[CGFClaimLineItemFilter]
(
[ClaimLineItemID] [int] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [fk] ON [dbo].[CGFClaimLineItemFilter] ([ClaimLineItemID]) ON [PRIMARY]
GO
CREATE STATISTICS [sp] ON [dbo].[CGFClaimLineItemFilter] ([ClaimLineItemID])
GO
