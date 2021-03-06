CREATE TABLE [dbo].[AO_950DC3_TC_EVENTS_INVITEES]
(
[EVENT_ID] [int] NULL,
[ID] [int] NOT NULL IDENTITY(1, 1),
[INVITEE_ID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AO_950DC3_TC_EVENTS_INVITEES] ADD CONSTRAINT [pk_AO_950DC3_TC_EVENTS_INVITEES_ID] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AO_950DC3_TC_EVENTS_INVITEES] ADD CONSTRAINT [fk_ao_950dc3_tc_events_invitees_event_id] FOREIGN KEY ([EVENT_ID]) REFERENCES [dbo].[AO_950DC3_TC_EVENTS] ([ID])
GO
