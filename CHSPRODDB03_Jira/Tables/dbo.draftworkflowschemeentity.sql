CREATE TABLE [dbo].[draftworkflowschemeentity]
(
[ID] [numeric] (18, 0) NOT NULL,
[SCHEME] [numeric] (18, 0) NULL,
[WORKFLOW] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[issuetype] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[draftworkflowschemeentity] ADD CONSTRAINT [PK_draftworkflowschemeentity] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [draft_workflow_scheme] ON [dbo].[draftworkflowschemeentity] ([SCHEME]) ON [PRIMARY]
GO
