CREATE TABLE [dbo].[cwd_directory]
(
[ID] [numeric] (18, 0) NOT NULL,
[directory_name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[lower_directory_name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[created_date] [datetime] NULL,
[updated_date] [datetime] NULL,
[active] [int] NULL,
[description] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[impl_class] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[lower_impl_class] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[directory_type] [nvarchar] (60) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[directory_position] [numeric] (18, 0) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cwd_directory] ADD CONSTRAINT [PK_cwd_directory] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_directory_active] ON [dbo].[cwd_directory] ([active]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_directory_type] ON [dbo].[cwd_directory] ([directory_type]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [uk_directory_name] ON [dbo].[cwd_directory] ([lower_directory_name]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_directory_impl] ON [dbo].[cwd_directory] ([lower_impl_class]) ON [PRIMARY]
GO
