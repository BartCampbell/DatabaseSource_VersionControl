CREATE TABLE [Measure].[Measures]
(
[Abbrev] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AllowHospice] [bit] NOT NULL CONSTRAINT [DF_Measures_AllowHospice] DEFAULT ((0)),
[CertDate] [smalldatetime] NULL,
[Descr] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsEnabled] [bit] NOT NULL CONSTRAINT [DF_Measures_IsEnabled] DEFAULT ((1)),
[IsHybrid] [bit] NOT NULL CONSTRAINT [DF_Measures_IsHybrid] DEFAULT ((0)),
[MeasClassID] [smallint] NOT NULL,
[MeasureGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_Measures_MeasureGuid] DEFAULT (newid()),
[MeasureID] [int] NOT NULL IDENTITY(1, 1),
[MeasureSetID] [int] NOT NULL,
[MeasureXrefID] [int] NULL,
[SysSampleRand] [decimal] (18, 6) NULL,
[SysSampleRate] [decimal] (18, 6) NULL,
[SysSampleSize] [smallint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Measure].[Measures] ADD CONSTRAINT [PK_Measures] PRIMARY KEY CLUSTERED  ([MeasureID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Measures_Abbrev] ON [Measure].[Measures] ([Abbrev], [MeasureSetID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Measures_MeasureGuid] ON [Measure].[Measures] ([MeasureGuid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Measures_MeasureSetID] ON [Measure].[Measures] ([MeasureSetID]) ON [PRIMARY]
GO
