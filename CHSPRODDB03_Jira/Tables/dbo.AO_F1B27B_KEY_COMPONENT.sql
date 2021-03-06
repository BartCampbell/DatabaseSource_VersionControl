CREATE TABLE [dbo].[AO_F1B27B_KEY_COMPONENT]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[KEY] [nvarchar] (450) COLLATE SQL_Latin1_General_CP437_CI_AI NOT NULL,
[TIMED_PROMISE_ID] [int] NOT NULL,
[VALUE] [nvarchar] (450) COLLATE SQL_Latin1_General_CP437_CI_AI NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AO_F1B27B_KEY_COMPONENT] ADD CONSTRAINT [pk_AO_F1B27B_KEY_COMPONENT_ID] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [index_ao_f1b27b_key473010270] ON [dbo].[AO_F1B27B_KEY_COMPONENT] ([TIMED_PROMISE_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AO_F1B27B_KEY_COMPONENT] ADD CONSTRAINT [fk_ao_f1b27b_key_component_timed_promise_id] FOREIGN KEY ([TIMED_PROMISE_ID]) REFERENCES [dbo].[AO_F1B27B_PROMISE] ([ID])
GO
