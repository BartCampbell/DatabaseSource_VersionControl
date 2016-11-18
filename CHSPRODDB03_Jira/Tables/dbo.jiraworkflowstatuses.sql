CREATE TABLE [dbo].[jiraworkflowstatuses]
(
[ID] [numeric] (18, 0) NOT NULL,
[status] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[parentname] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[jiraworkflowstatuses] ADD CONSTRAINT [PK_jiraworkflowstatuses] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_parent_name] ON [dbo].[jiraworkflowstatuses] ([parentname]) ON [PRIMARY]
GO
