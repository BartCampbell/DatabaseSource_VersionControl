CREATE TABLE [Measure].[EventSourceTypes]
(
[ClaimSrcTypeID] [tinyint] NOT NULL,
[EventID] [int] NOT NULL,
[IsValid] [bit] NOT NULL CONSTRAINT [DF_EventSourceTypes_IsValid] DEFAULT ((1))
) ON [PRIMARY]
GO
ALTER TABLE [Measure].[EventSourceTypes] ADD CONSTRAINT [PK_Measure_EventSourceTypes] PRIMARY KEY CLUSTERED  ([EventID], [ClaimSrcTypeID]) ON [PRIMARY]
GO
