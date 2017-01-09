CREATE TABLE [dbo].[tblExtractionQueueSource]
(
[ExtractionQueueSource_PK] [tinyint] NOT NULL IDENTITY(1, 1),
[SourceName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SourcePath] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblExtractionQueueSource] ADD CONSTRAINT [PK_tblExtractionQueueSource] PRIMARY KEY CLUSTERED  ([ExtractionQueueSource_PK]) ON [PRIMARY]
GO
