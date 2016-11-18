CREATE TABLE [dbo].[cwd_group]
(
[ID] [numeric] (18, 0) NOT NULL,
[group_name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[lower_group_name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[active] [int] NULL,
[local] [int] NULL,
[created_date] [datetime] NULL,
[updated_date] [datetime] NULL,
[description] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[lower_description] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[group_type] [nvarchar] (60) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[directory_id] [numeric] (18, 0) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cwd_group] ADD CONSTRAINT [PK_cwd_group] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_group_dir_id] ON [dbo].[cwd_group] ([directory_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_group_active] ON [dbo].[cwd_group] ([lower_group_name], [active]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [uk_group_name_dir_id] ON [dbo].[cwd_group] ([lower_group_name], [directory_id]) ON [PRIMARY]
GO
