CREATE TABLE [dbo].[AO_60DB71_RAPIDVIEW]
(
[CARD_COLOR_STRATEGY] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[ID] [bigint] NOT NULL IDENTITY(1, 1),
[NAME] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NOT NULL,
[OWNER_USER_NAME] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NOT NULL,
[SAVED_FILTER_ID] [bigint] NOT NULL,
[SHOW_DAYS_IN_COLUMN] [bit] NULL,
[SPRINTS_ENABLED] [bit] NULL,
[SPRINT_MARKERS_MIGRATED] [bit] NULL,
[SWIMLANE_STRATEGY] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[KAN_PLAN_ENABLED] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AO_60DB71_RAPIDVIEW] ADD CONSTRAINT [pk_AO_60DB71_RAPIDVIEW_ID] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO