CREATE TABLE [dbo].[cwd_membership]
(
[id] [numeric] (19, 0) NOT NULL,
[parent_id] [numeric] (19, 0) NOT NULL,
[child_group_id] [numeric] (19, 0) NULL,
[child_user_id] [numeric] (19, 0) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cwd_membership] ADD CONSTRAINT [PK__cwd_memb__3213E83F88B8480D] PRIMARY KEY CLUSTERED  ([id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_mem_dir_child] ON [dbo].[cwd_membership] ([child_group_id], [child_user_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_mem_dir_child_user] ON [dbo].[cwd_membership] ([child_user_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_mem_dir_parent] ON [dbo].[cwd_membership] ([parent_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cwd_membership] ADD CONSTRAINT [cwd_unique_membership] UNIQUE NONCLUSTERED  ([parent_id], [child_group_id], [child_user_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_mem_dir_parent_child] ON [dbo].[cwd_membership] ([parent_id], [child_group_id], [child_user_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cwd_membership] ADD CONSTRAINT [fk_child_grp] FOREIGN KEY ([child_group_id]) REFERENCES [dbo].[cwd_group] ([id])
GO
ALTER TABLE [dbo].[cwd_membership] ADD CONSTRAINT [fk_child_user] FOREIGN KEY ([child_user_id]) REFERENCES [dbo].[cwd_user] ([id])
GO
ALTER TABLE [dbo].[cwd_membership] ADD CONSTRAINT [fk_parent_grp] FOREIGN KEY ([parent_id]) REFERENCES [dbo].[cwd_group] ([id])
GO
