CREATE TABLE [dbo].[cwd_user]
(
[id] [numeric] (19, 0) NOT NULL,
[user_name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[lower_user_name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[active] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[created_date] [datetime] NOT NULL,
[updated_date] [datetime] NOT NULL,
[first_name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[lower_first_name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[last_name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[lower_last_name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[display_name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[lower_display_name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[email_address] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[lower_email_address] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[external_id] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[directory_id] [numeric] (19, 0) NOT NULL,
[credential] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cwd_user] ADD CONSTRAINT [PK__cwd_user__3213E83FF908A22E] PRIMARY KEY CLUSTERED  ([id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_user_active] ON [dbo].[cwd_user] ([active], [directory_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_user_name_dir_id] ON [dbo].[cwd_user] ([directory_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_user_external_id] ON [dbo].[cwd_user] ([external_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_user_lower_display_name] ON [dbo].[cwd_user] ([lower_display_name], [directory_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_user_lower_email_address] ON [dbo].[cwd_user] ([lower_email_address], [directory_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_user_lower_first_name] ON [dbo].[cwd_user] ([lower_first_name], [directory_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_user_lower_last_name] ON [dbo].[cwd_user] ([lower_last_name], [directory_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cwd_user] ADD CONSTRAINT [cwd_user_name_dir_id] UNIQUE NONCLUSTERED  ([lower_user_name], [directory_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cwd_user] ADD CONSTRAINT [fk_user_dir_id] FOREIGN KEY ([directory_id]) REFERENCES [dbo].[cwd_directory] ([id])
GO
