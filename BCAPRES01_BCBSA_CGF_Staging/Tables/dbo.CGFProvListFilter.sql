CREATE TABLE [dbo].[CGFProvListFilter]
(
[ProviderID] [int] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [fk] ON [dbo].[CGFProvListFilter] ([ProviderID]) ON [PRIMARY]
GO
CREATE STATISTICS [sp] ON [dbo].[CGFProvListFilter] ([ProviderID])
GO
