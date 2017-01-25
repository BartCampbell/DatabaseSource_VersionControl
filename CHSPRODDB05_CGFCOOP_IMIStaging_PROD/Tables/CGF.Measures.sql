CREATE TABLE [CGF].[Measures]
(
[Measure] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Abbrev] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Descr] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsEnabled] [bit] NOT NULL,
[MeasClassID] [int] NOT NULL,
[MeasureSetTypeID] [smallint] NOT NULL,
[MeasureXrefGuid] [uniqueidentifier] NOT NULL,
[MeasureXrefID] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Measures_Measure] ON [CGF].[Measures] ([Measure]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Measures] ON [CGF].[Measures] ([MeasureXrefGuid]) ON [PRIMARY]
GO
CREATE STATISTICS [spIX_Measures_Measure] ON [CGF].[Measures] ([Measure])
GO
CREATE STATISTICS [spIX_Measures] ON [CGF].[Measures] ([MeasureXrefGuid])
GO
