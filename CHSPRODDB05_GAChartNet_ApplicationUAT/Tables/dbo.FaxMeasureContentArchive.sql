CREATE TABLE [dbo].[FaxMeasureContentArchive]
(
[ClientID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MeasureID] [int] NOT NULL,
[FaxMeasureInstruction] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveDate] [datetime] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[FaxMeasureContentArchive] ADD CONSTRAINT [PK_FaxMeasureContentArchive] PRIMARY KEY CLUSTERED  ([ClientID], [MeasureID], [ArchiveDate]) ON [PRIMARY]
GO
