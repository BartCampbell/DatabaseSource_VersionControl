CREATE TABLE [dbo].[cwd_membership]
(
[ID] [numeric] (18, 0) NOT NULL,
[parent_id] [numeric] (18, 0) NULL,
[child_id] [numeric] (18, 0) NULL,
[membership_type] [nvarchar] (60) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[group_type] [nvarchar] (60) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[parent_name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[lower_parent_name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[child_name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[lower_child_name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[directory_id] [numeric] (18, 0) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cwd_membership] ADD CONSTRAINT [PK_cwd_membership] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_mem_dir_child] ON [dbo].[cwd_membership] ([lower_child_name], [membership_type], [directory_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_mem_dir_parent_child] ON [dbo].[cwd_membership] ([lower_parent_name], [lower_child_name], [membership_type], [directory_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_mem_dir_parent] ON [dbo].[cwd_membership] ([lower_parent_name], [membership_type], [directory_id]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [uk_mem_parent_child_type] ON [dbo].[cwd_membership] ([parent_id], [child_id], [membership_type]) ON [PRIMARY]
GO
