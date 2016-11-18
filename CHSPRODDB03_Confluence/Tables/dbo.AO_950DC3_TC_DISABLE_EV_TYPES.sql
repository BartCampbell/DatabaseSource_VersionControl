CREATE TABLE [dbo].[AO_950DC3_TC_DISABLE_EV_TYPES]
(
[EVENT_KEY] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ID] [int] NOT NULL IDENTITY(1, 1),
[SUB_CALENDAR_ID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AO_950DC3_TC_DISABLE_EV_TYPES] ADD CONSTRAINT [pk_AO_950DC3_TC_DISABLE_EV_TYPES_ID] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AO_950DC3_TC_DISABLE_EV_TYPES] ADD CONSTRAINT [fk_ao_950dc3_tc_disable_ev_types_sub_calendar_id] FOREIGN KEY ([SUB_CALENDAR_ID]) REFERENCES [dbo].[AO_950DC3_TC_SUBCALS] ([ID])
GO
