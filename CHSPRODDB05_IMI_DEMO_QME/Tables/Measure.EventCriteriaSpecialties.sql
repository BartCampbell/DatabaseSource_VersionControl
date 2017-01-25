CREATE TABLE [Measure].[EventCriteriaSpecialties]
(
[EventCritID] [int] NOT NULL,
[IsValid] [bit] NOT NULL CONSTRAINT [DF_EventCriteriaSpecialties_IsValid] DEFAULT ((1)),
[SpecialtyID] [smallint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Measure].[EventCriteriaSpecialties] ADD CONSTRAINT [PK_EventCriteriaSpecialties] PRIMARY KEY CLUSTERED  ([EventCritID], [SpecialtyID]) ON [PRIMARY]
GO
