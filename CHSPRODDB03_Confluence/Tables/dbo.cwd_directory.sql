CREATE TABLE [dbo].[cwd_directory]
(
[id] [numeric] (19, 0) NOT NULL,
[directory_name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[lower_directory_name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[created_date] [datetime] NOT NULL,
[updated_date] [datetime] NOT NULL,
[active] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[description] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[impl_class] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[lower_impl_class] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[directory_type] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cwd_directory] ADD CONSTRAINT [PK__cwd_dire__3213E83F654B528C] PRIMARY KEY CLUSTERED  ([id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_dir_active] ON [dbo].[cwd_directory] ([active]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_dir_type] ON [dbo].[cwd_directory] ([directory_type]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cwd_directory] ADD CONSTRAINT [UQ__cwd_dire__50E22DBCB5AABD5B] UNIQUE NONCLUSTERED  ([lower_directory_name]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_dir_l_impl_class] ON [dbo].[cwd_directory] ([lower_impl_class]) ON [PRIMARY]
GO
