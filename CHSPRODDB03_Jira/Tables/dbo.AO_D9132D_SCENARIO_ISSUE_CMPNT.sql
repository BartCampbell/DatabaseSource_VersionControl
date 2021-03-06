CREATE TABLE [dbo].[AO_D9132D_SCENARIO_ISSUE_CMPNT]
(
[COMPONENT_ID] [bigint] NULL,
[ID] [bigint] NOT NULL IDENTITY(1, 1),
[SCENARIO_ISSUE_ID] [bigint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AO_D9132D_SCENARIO_ISSUE_CMPNT] ADD CONSTRAINT [pk_AO_D9132D_SCENARIO_ISSUE_CMPNT_ID] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [index_ao_d9132d_sce1508270445] ON [dbo].[AO_D9132D_SCENARIO_ISSUE_CMPNT] ([COMPONENT_ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [index_ao_d9132d_sce824201434] ON [dbo].[AO_D9132D_SCENARIO_ISSUE_CMPNT] ([SCENARIO_ISSUE_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AO_D9132D_SCENARIO_ISSUE_CMPNT] ADD CONSTRAINT [fk_ao_d9132d_scenario_issue_cmpnt_scenario_issue_id] FOREIGN KEY ([SCENARIO_ISSUE_ID]) REFERENCES [dbo].[AO_D9132D_SCENARIO_ISSUES] ([ID])
GO
