CREATE TABLE [stage].[ExtractionQueue_ADV]
(
[CentauriExtractionQueueID] [int] NOT NULL,
[Assigned_CentauriUserID] [int] NULL,
[PDFname] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtractionQueueSource_PK] [tinyint] NULL,
[FileSize] [bigint] NULL,
[IsDuplicate] [bit] NULL,
[UploadDate] [smalldatetime] NULL,
[AssignedDate] [smalldatetime] NULL,
[OfficeFaxOrID] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL
) ON [PRIMARY]
GO
