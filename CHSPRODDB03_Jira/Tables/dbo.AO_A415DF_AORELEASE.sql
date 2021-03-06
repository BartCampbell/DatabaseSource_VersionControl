CREATE TABLE [dbo].[AO_A415DF_AORELEASE]
(
[AODELTA_START_DATE] [bigint] NULL,
[AOFIXED_END_DATE] [bigint] NULL,
[AOFIXED_START_DATE] [bigint] NULL,
[AOPLAN_ID] [int] NULL,
[AOSTREAM_ID] [int] NULL,
[DESCRIPTION] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[DETAILS] [ntext] COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[ID_OTHER] [int] NOT NULL IDENTITY(1, 1),
[IS_LATER_RELEASE] [bit] NULL,
[ORDER_RANGE_IDENTIFIER] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[PRIMARY_VERSION] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[SORT_ORDER] [bigint] NULL,
[TITLE] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[VERSION] [bigint] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[AO_A415DF_AORELEASE] ADD CONSTRAINT [pk_AO_A415DF_AORELEASE_ID_OTHER] PRIMARY KEY CLUSTERED  ([ID_OTHER]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [index_ao_a415df_aor752754629] ON [dbo].[AO_A415DF_AORELEASE] ([AOPLAN_ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [index_ao_a415df_aor34455044] ON [dbo].[AO_A415DF_AORELEASE] ([AOSTREAM_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AO_A415DF_AORELEASE] ADD CONSTRAINT [fk_ao_a415df_aorelease_aoplan_id] FOREIGN KEY ([AOPLAN_ID]) REFERENCES [dbo].[AO_A415DF_AOPLAN] ([ID_OTHER])
GO
ALTER TABLE [dbo].[AO_A415DF_AORELEASE] ADD CONSTRAINT [fk_ao_a415df_aorelease_aostream_id] FOREIGN KEY ([AOSTREAM_ID]) REFERENCES [dbo].[AO_A415DF_AOSTREAM] ([ID_OTHER])
GO
