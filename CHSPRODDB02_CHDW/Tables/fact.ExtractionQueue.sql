CREATE TABLE [fact].[ExtractionQueue]
(
[ExtractionQueueID] [int] NOT NULL IDENTITY(1, 1),
[CentauriExtractionQueueID] [int] NOT NULL,
[Assigned_UserID] [int] NULL,
[PDFname] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtractionQueueSource_PK] [tinyint] NULL,
[FileSize] [bigint] NULL,
[IsDuplicate] [bit] NULL,
[UploadDate] [smalldatetime] NULL,
[AssignedDate] [smalldatetime] NULL,
[OfficeFaxOrID] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreateDate] [datetime] NULL CONSTRAINT [DF_ExtractionQueue_CreateDate] DEFAULT (getdate()),
[LastUpdate] [datetime] NULL CONSTRAINT [DF_ProviderExtractionQueue_LastUpdate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [fact].[ExtractionQueue] ADD CONSTRAINT [PK_ExtractionQueue] PRIMARY KEY CLUSTERED  ([ExtractionQueueID]) ON [PRIMARY]
GO
ALTER TABLE [fact].[ExtractionQueue] ADD CONSTRAINT [FK_ExtractionQueue_User] FOREIGN KEY ([Assigned_UserID]) REFERENCES [dim].[User] ([UserID])
GO
