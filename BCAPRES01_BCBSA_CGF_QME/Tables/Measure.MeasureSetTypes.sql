CREATE TABLE [Measure].[MeasureSetTypes]
(
[Abbrev] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Descr] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MeasureSetTypeGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_MeasureSetTypes_MeasureSetTypeGuid] DEFAULT (newid()),
[MeasureSetTypeID] [smallint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Measure].[MeasureSetTypes] ADD CONSTRAINT [PK_MeasureSetTypes] PRIMARY KEY CLUSTERED  ([MeasureSetTypeID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_MeasureSetTypes_Abbrev] ON [Measure].[MeasureSetTypes] ([Abbrev]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_MeasureSetTypes_MeasureSetTypeGuid] ON [Measure].[MeasureSetTypes] ([MeasureSetTypeGuid]) ON [PRIMARY]
GO
