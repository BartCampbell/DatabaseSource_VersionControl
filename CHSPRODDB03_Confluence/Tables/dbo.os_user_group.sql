CREATE TABLE [dbo].[os_user_group]
(
[group_id] [numeric] (19, 0) NOT NULL,
[user_id] [numeric] (19, 0) NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[os_user_group] ADD CONSTRAINT [PK__os_user___A4E94E5522261678] PRIMARY KEY CLUSTERED  ([user_id], [group_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [c_groupdid_idx] ON [dbo].[os_user_group] ([group_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[os_user_group] ADD CONSTRAINT [FK932472461E2E76DB] FOREIGN KEY ([group_id]) REFERENCES [dbo].[os_group] ([id])
GO
ALTER TABLE [dbo].[os_user_group] ADD CONSTRAINT [FK93247246F73AEE0F] FOREIGN KEY ([user_id]) REFERENCES [dbo].[os_user] ([id])
GO
