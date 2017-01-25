CREATE TABLE [Result].[MeasureXrefs]
(
[Abbrev] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Descr] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MeasClassID] [int] NOT NULL,
[MeasureSetTypeID] [smallint] NOT NULL,
[MeasureXrefGuid] [uniqueidentifier] NOT NULL,
[MeasureXrefID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Result].[MeasureXrefs] ADD CONSTRAINT [PK_Result_MeasureXrefs] PRIMARY KEY CLUSTERED  ([MeasureXrefID]) ON [PRIMARY]
GO
