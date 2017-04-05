CREATE TABLE [Measure].[CustomProcessTypes]
(
[Abbrev] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Descr] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MeasProcTypeGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_CustomProcessTypes_MeasProcTypeGuid] DEFAULT (newid()),
[MeasProcTypeID] [tinyint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Measure].[CustomProcessTypes] ADD CONSTRAINT [PK_CustomProcessTypes] PRIMARY KEY CLUSTERED  ([MeasProcTypeID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_CustomProcessTypes_Abbrev] ON [Measure].[CustomProcessTypes] ([Abbrev]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_CustomProcessTypes_MeasProcTypeGuid] ON [Measure].[CustomProcessTypes] ([MeasProcTypeGuid]) ON [PRIMARY]
GO
