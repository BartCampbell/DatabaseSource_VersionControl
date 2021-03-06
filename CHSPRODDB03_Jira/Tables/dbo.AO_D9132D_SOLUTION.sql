CREATE TABLE [dbo].[AO_D9132D_SOLUTION]
(
[HEARTBEAT_TIMESTAMP] [datetime] NOT NULL,
[ID] [bigint] NOT NULL IDENTITY(1, 1),
[PLAN] [bigint] NOT NULL,
[SCHEDULABLE_ISSUE_COUNT] [bigint] NULL,
[SCHEDULED_ISSUE_COUNT] [bigint] NULL,
[SOLUTION] [ntext] COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[STATE] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NOT NULL,
[TRIGGER_TIMESTAMP] [datetime] NOT NULL,
[UNIQUE_GUARD] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NOT NULL,
[VERSION] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[AO_D9132D_SOLUTION] ADD CONSTRAINT [pk_AO_D9132D_SOLUTION_ID] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [index_ao_d9132d_solution_plan] ON [dbo].[AO_D9132D_SOLUTION] ([PLAN]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [index_ao_d9132d_solution_state] ON [dbo].[AO_D9132D_SOLUTION] ([STATE]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AO_D9132D_SOLUTION] ADD CONSTRAINT [U_AO_D9132D_SOLUTIO277170766] UNIQUE NONCLUSTERED  ([UNIQUE_GUARD]) ON [PRIMARY]
GO
