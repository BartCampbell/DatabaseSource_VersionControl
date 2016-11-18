CREATE TABLE [dbo].[workflowschemeentity]
(
[ID] [numeric] (18, 0) NOT NULL,
[SCHEME] [numeric] (18, 0) NULL,
[WORKFLOW] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[issuetype] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[workflowschemeentity] ADD CONSTRAINT [PK_workflowschemeentity] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [workflow_scheme] ON [dbo].[workflowschemeentity] ([SCHEME]) ON [PRIMARY]
GO
