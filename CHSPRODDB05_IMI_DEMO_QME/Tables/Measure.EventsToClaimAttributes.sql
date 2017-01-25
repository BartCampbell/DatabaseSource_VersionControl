CREATE TABLE [Measure].[EventsToClaimAttributes]
(
[ClaimAttribID] [smallint] NOT NULL,
[EventID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Measure].[EventsToClaimAttributes] ADD CONSTRAINT [CK_EventsToClaimAttributes_EventTypeID] CHECK (([Measure].[GetEventType]([EventID])=(2)))
GO
ALTER TABLE [Measure].[EventsToClaimAttributes] ADD CONSTRAINT [PK_EventsToClaimAttributes] PRIMARY KEY CLUSTERED  ([EventID], [ClaimAttribID]) ON [PRIMARY]
GO
ALTER TABLE [Measure].[EventsToClaimAttributes] ADD CONSTRAINT [IX_EventsToClaimAttributes] UNIQUE NONCLUSTERED  ([EventID]) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Events associated with Claim Attributes must be of the claim-line-matching type.', 'SCHEMA', N'Measure', 'TABLE', N'EventsToClaimAttributes', 'CONSTRAINT', N'CK_EventsToClaimAttributes_EventTypeID'
GO
