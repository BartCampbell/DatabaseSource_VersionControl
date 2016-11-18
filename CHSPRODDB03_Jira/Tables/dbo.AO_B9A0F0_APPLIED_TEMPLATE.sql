CREATE TABLE [dbo].[AO_B9A0F0_APPLIED_TEMPLATE]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[PROJECT_ID] [bigint] NULL CONSTRAINT [df_AO_B9A0F0_APPLIED_TEMPLATE_PROJECT_ID] DEFAULT ((0)),
[PROJECT_TEMPLATE_MODULE_KEY] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[PROJECT_TEMPLATE_WEB_ITEM_KEY] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AO_B9A0F0_APPLIED_TEMPLATE] ADD CONSTRAINT [pk_AO_B9A0F0_APPLIED_TEMPLATE_ID] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO