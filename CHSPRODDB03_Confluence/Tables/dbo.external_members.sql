CREATE TABLE [dbo].[external_members]
(
[extentityid] [numeric] (19, 0) NOT NULL,
[groupid] [numeric] (19, 0) NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[external_members] ADD CONSTRAINT [PK__external__10ED95097B1D1F5F] PRIMARY KEY CLUSTERED  ([groupid], [extentityid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [c_extentityid_idx] ON [dbo].[external_members] ([extentityid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[external_members] ADD CONSTRAINT [FKD8C8D8A5117D5FDA] FOREIGN KEY ([groupid]) REFERENCES [dbo].[groups] ([id])
GO
ALTER TABLE [dbo].[external_members] ADD CONSTRAINT [FKD8C8D8A5F25E5D5F] FOREIGN KEY ([extentityid]) REFERENCES [dbo].[external_entities] ([id])
GO
