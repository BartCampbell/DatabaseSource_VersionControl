CREATE TABLE [dbo].[project_key]
(
[ID] [numeric] (18, 0) NOT NULL,
[PROJECT_ID] [numeric] (18, 0) NULL,
[PROJECT_KEY] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[project_key] ADD CONSTRAINT [PK_project_key] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_all_project_ids] ON [dbo].[project_key] ([PROJECT_ID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [idx_all_project_keys] ON [dbo].[project_key] ([PROJECT_KEY]) ON [PRIMARY]
GO
