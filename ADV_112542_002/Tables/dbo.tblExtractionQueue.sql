CREATE TABLE [dbo].[tblExtractionQueue]
(
[ExtractionQueue_PK] [int] NOT NULL IDENTITY(1, 1),
[PDFname] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtractionQueueSource_PK] [tinyint] NULL,
[FileSize] [bigint] NULL,
[AssignedUser_PK] [smallint] NULL,
[IsDuplicate] [bit] NULL,
[UploadDate] [smalldatetime] NULL,
[AssignedDate] [smalldatetime] NULL,
[OfficeFaxOrID] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblExtractionQueue] ADD CONSTRAINT [PK_tblExtractionQueue] PRIMARY KEY CLUSTERED  ([ExtractionQueue_PK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblExtractionQueue_User] ON [dbo].[tblExtractionQueue] ([AssignedUser_PK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblExtractionQueueUserSource] ON [dbo].[tblExtractionQueue] ([ExtractionQueueSource_PK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_OfficeExtractUploadDate] ON [dbo].[tblExtractionQueue] ([OfficeFaxOrID], [ExtractionQueueSource_PK], [UploadDate]) ON [PRIMARY]
GO
