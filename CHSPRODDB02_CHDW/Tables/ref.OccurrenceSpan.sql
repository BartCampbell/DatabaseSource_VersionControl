CREATE TABLE [ref].[OccurrenceSpan]
(
[OccurrenceSpanID] [int] NOT NULL IDENTITY(1, 1),
[OccurrenceSpanCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OccurrenceSpan] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EffectiveStartDate] [datetime] NOT NULL,
[EffectiveEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [ref].[OccurrenceSpan] ADD CONSTRAINT [PK_OccurrenceSpan] PRIMARY KEY CLUSTERED  ([OccurrenceSpanID]) ON [PRIMARY]
GO
