CREATE TABLE [ref].[Occurrence]
(
[OccurrenceID] [int] NOT NULL IDENTITY(1, 1),
[OccurrenceCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Occurrence] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EffectiveStartDate] [datetime] NOT NULL,
[EffectiveEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [ref].[Occurrence] ADD CONSTRAINT [PK_Occurrence] PRIMARY KEY CLUSTERED  ([OccurrenceID]) ON [PRIMARY]
GO
