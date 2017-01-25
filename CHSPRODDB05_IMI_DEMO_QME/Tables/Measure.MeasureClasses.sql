CREATE TABLE [Measure].[MeasureClasses]
(
[Abbrev] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Descr] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MeasClassID] [smallint] NOT NULL IDENTITY(1, 1),
[ParentID] [smallint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Measure].[MeasureClasses] ADD CONSTRAINT [PK_MeasureClasses] PRIMARY KEY CLUSTERED  ([MeasClassID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_MeasureClasses_Abbrev] ON [Measure].[MeasureClasses] ([Abbrev]) ON [PRIMARY]
GO
