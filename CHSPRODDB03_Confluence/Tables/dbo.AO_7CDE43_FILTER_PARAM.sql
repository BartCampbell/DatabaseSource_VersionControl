CREATE TABLE [dbo].[AO_7CDE43_FILTER_PARAM]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[NOTIFICATION_ID] [int] NULL,
[PARAM_KEY] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[PARAM_VALUE] [ntext] COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[AO_7CDE43_FILTER_PARAM] ADD CONSTRAINT [pk_AO_7CDE43_FILTER_PARAM_ID] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [index_ao_7cde43_fil1140550715] ON [dbo].[AO_7CDE43_FILTER_PARAM] ([NOTIFICATION_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AO_7CDE43_FILTER_PARAM] ADD CONSTRAINT [fk_ao_7cde43_filter_param_notification_id] FOREIGN KEY ([NOTIFICATION_ID]) REFERENCES [dbo].[AO_7CDE43_NOTIFICATION] ([ID])
GO
