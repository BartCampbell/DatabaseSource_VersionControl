CREATE TABLE [dbo].[tmp_provider]
(
[ProviderID] [int] NULL,
[ihds_prov_id] [int] NULL
) ON [Tmp_Drive04]
GO
CREATE NONCLUSTERED INDEX [idx] ON [dbo].[tmp_provider] ([ProviderID], [ihds_prov_id]) ON [Tmp_Drive04]
GO
CREATE STATISTICS [spidx] ON [dbo].[tmp_provider] ([ProviderID], [ihds_prov_id])
GO
