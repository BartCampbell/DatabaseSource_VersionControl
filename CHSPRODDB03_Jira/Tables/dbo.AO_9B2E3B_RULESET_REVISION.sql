CREATE TABLE [dbo].[AO_9B2E3B_RULESET_REVISION]
(
[CREATED_BY] [nvarchar] (127) COLLATE SQL_Latin1_General_CP437_CI_AI NOT NULL,
[CREATED_TIMESTAMP_MILLIS] [bigint] NULL,
[DESCRIPTION] [nvarchar] (450) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[ID] [bigint] NOT NULL IDENTITY(1, 1),
[NAME] [nvarchar] (127) COLLATE SQL_Latin1_General_CP437_CI_AI NOT NULL,
[RULE_SET_ID] [bigint] NOT NULL,
[TRIGGER_FROM_OTHER_RULES] [bit] NULL,
[IS_SYSTEM_RULE_SET] [bit] NOT NULL CONSTRAINT [df_AO_9B2E3B_RULESET_REVISION_IS_SYSTEM_RULE_SET] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AO_9B2E3B_RULESET_REVISION] ADD CONSTRAINT [pk_AO_9B2E3B_RULESET_REVISION_ID] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [index_ao_9b2e3b_rul106976704] ON [dbo].[AO_9B2E3B_RULESET_REVISION] ([RULE_SET_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AO_9B2E3B_RULESET_REVISION] ADD CONSTRAINT [fk_ao_9b2e3b_ruleset_revision_rule_set_id] FOREIGN KEY ([RULE_SET_ID]) REFERENCES [dbo].[AO_9B2E3B_RULESET] ([ID])
GO