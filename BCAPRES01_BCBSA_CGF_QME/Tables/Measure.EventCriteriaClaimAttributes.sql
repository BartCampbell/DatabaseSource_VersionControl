CREATE TABLE [Measure].[EventCriteriaClaimAttributes]
(
[ClaimAttribID] [smallint] NOT NULL,
[IsValid] [bit] NOT NULL CONSTRAINT [DF_EventCriteriaClaimAttributes_IsValid] DEFAULT ((1)),
[EventCritID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Measure].[EventCriteriaClaimAttributes] ADD CONSTRAINT [PK_EventCriteriaClaimAttributes] PRIMARY KEY CLUSTERED  ([EventCritID], [ClaimAttribID]) ON [PRIMARY]
GO
