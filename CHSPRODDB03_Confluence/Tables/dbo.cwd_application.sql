CREATE TABLE [dbo].[cwd_application]
(
[id] [numeric] (19, 0) NOT NULL,
[application_name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[lower_application_name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[created_date] [datetime] NOT NULL,
[updated_date] [datetime] NOT NULL,
[active] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[description] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[application_type] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[credential] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cwd_application] ADD CONSTRAINT [PK__cwd_appl__3213E83F28136C32] PRIMARY KEY CLUSTERED  ([id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_app_active] ON [dbo].[cwd_application] ([active]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_app_type] ON [dbo].[cwd_application] ([application_type]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cwd_application] ADD CONSTRAINT [UQ__cwd_appl__27A64F3CB116D9FA] UNIQUE NONCLUSTERED  ([lower_application_name]) ON [PRIMARY]
GO
