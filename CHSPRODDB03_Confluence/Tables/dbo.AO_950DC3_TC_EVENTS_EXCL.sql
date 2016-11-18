CREATE TABLE [dbo].[AO_950DC3_TC_EVENTS_EXCL]
(
[ALL_DAY] [bit] NULL,
[EVENT_ID] [int] NULL,
[EXCLUSION] [bigint] NULL,
[ID] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AO_950DC3_TC_EVENTS_EXCL] ADD CONSTRAINT [pk_AO_950DC3_TC_EVENTS_EXCL_ID] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AO_950DC3_TC_EVENTS_EXCL] ADD CONSTRAINT [fk_ao_950dc3_tc_events_excl_event_id] FOREIGN KEY ([EVENT_ID]) REFERENCES [dbo].[AO_950DC3_TC_EVENTS] ([ID])
GO
