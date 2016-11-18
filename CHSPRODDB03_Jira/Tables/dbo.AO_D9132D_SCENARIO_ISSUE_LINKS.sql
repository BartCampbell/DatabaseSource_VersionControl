CREATE TABLE [dbo].[AO_D9132D_SCENARIO_ISSUE_LINKS]
(
[C_KEY] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NOT NULL,
[ID] [bigint] NOT NULL IDENTITY(1, 1),
[ITEM_KEY] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NOT NULL,
[LAST_CHANGE_TIMESTAMP] [bigint] NULL,
[LAST_CHANGE_USER] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[LINK_TYPE] [bigint] NULL,
[LINK_TYPE_CHANGED] [bit] NULL,
[SCENARIO_ID] [bigint] NULL,
[SCENARIO_TYPE] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NOT NULL,
[SOURCE] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[TARGET] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AO_D9132D_SCENARIO_ISSUE_LINKS] ADD CONSTRAINT [pk_AO_D9132D_SCENARIO_ISSUE_LINKS_ID] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AO_D9132D_SCENARIO_ISSUE_LINKS] ADD CONSTRAINT [U_AO_D9132D_SCENARI887167849] UNIQUE NONCLUSTERED  ([C_KEY]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [index_ao_d9132d_sce304701852] ON [dbo].[AO_D9132D_SCENARIO_ISSUE_LINKS] ([ITEM_KEY]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [index_ao_d9132d_sce210160351] ON [dbo].[AO_D9132D_SCENARIO_ISSUE_LINKS] ([SCENARIO_ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [index_ao_d9132d_sce100282944] ON [dbo].[AO_D9132D_SCENARIO_ISSUE_LINKS] ([SCENARIO_TYPE]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [index_ao_d9132d_sce1348810556] ON [dbo].[AO_D9132D_SCENARIO_ISSUE_LINKS] ([SOURCE]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [index_ao_d9132d_sce1333210566] ON [dbo].[AO_D9132D_SCENARIO_ISSUE_LINKS] ([TARGET]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AO_D9132D_SCENARIO_ISSUE_LINKS] ADD CONSTRAINT [fk_ao_d9132d_scenario_issue_links_scenario_id] FOREIGN KEY ([SCENARIO_ID]) REFERENCES [dbo].[AO_D9132D_SCENARIO] ([ID])
GO