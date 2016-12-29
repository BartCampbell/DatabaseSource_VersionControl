CREATE TABLE [dbo].[tblExtractionQueue2Del]
(
[ExtractionQueue_PK] [int] NOT NULL,
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
