CREATE TABLE [dbo].[cwd_application]
(
[ID] [numeric] (18, 0) NOT NULL,
[application_name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[lower_application_name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[created_date] [datetime] NULL,
[updated_date] [datetime] NULL,
[active] [int] NULL,
[description] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[application_type] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[credential] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cwd_application] ADD CONSTRAINT [PK_cwd_application] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [uk_application_name] ON [dbo].[cwd_application] ([lower_application_name]) ON [PRIMARY]
GO
