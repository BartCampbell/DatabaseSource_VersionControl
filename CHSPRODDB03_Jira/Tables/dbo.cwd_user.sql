CREATE TABLE [dbo].[cwd_user]
(
[ID] [numeric] (18, 0) NOT NULL,
[directory_id] [numeric] (18, 0) NULL,
[user_name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[lower_user_name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[active] [int] NULL,
[created_date] [datetime] NULL,
[updated_date] [datetime] NULL,
[first_name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[lower_first_name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[last_name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[lower_last_name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[display_name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[lower_display_name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[email_address] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[lower_email_address] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[CREDENTIAL] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[deleted_externally] [int] NULL,
[EXTERNAL_ID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cwd_user] ADD CONSTRAINT [PK_cwd_user] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [uk_user_externalid_dir_id] ON [dbo].[cwd_user] ([EXTERNAL_ID], [directory_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_display_name] ON [dbo].[cwd_user] ([lower_display_name]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_email_address] ON [dbo].[cwd_user] ([lower_email_address]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_first_name] ON [dbo].[cwd_user] ([lower_first_name]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_last_name] ON [dbo].[cwd_user] ([lower_last_name]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [uk_user_name_dir_id] ON [dbo].[cwd_user] ([lower_user_name], [directory_id]) ON [PRIMARY]
GO
