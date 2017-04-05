CREATE TABLE [Ncqa].[MeasureKey]
(
[Abbrev] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Descr] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MeasClassID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Ncqa].[MeasureKey] ADD CONSTRAINT [PK_MeasureKey] PRIMARY KEY CLUSTERED  ([Abbrev]) ON [PRIMARY]
GO
