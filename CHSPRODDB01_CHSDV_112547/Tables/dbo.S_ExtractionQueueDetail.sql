CREATE TABLE [dbo].[S_ExtractionQueueDetail]
(
[S_ExtractionQueueDetail_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NULL,
[H_ExtractionQueue_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PDFname] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtractionQueueSource_PK] [tinyint] NULL,
[FileSize] [bigint] NULL,
[IsDuplicate] [bit] NULL,
[UploadDate] [smalldatetime] NULL,
[AssignedDate] [smalldatetime] NULL,
[OfficeFaxOrID] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashDiff] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_ExtractionQueueDetail] ADD CONSTRAINT [PK_S_ExtractionQueueDetail] PRIMARY KEY CLUSTERED  ([S_ExtractionQueueDetail_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20161003-081410] ON [dbo].[S_ExtractionQueueDetail] ([HashDiff]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_ExtractionQueueDetail] ADD CONSTRAINT [FK_H_ExtractionQueueDetail_RK2] FOREIGN KEY ([H_ExtractionQueue_RK]) REFERENCES [dbo].[H_ExtractionQueue] ([H_ExtractionQueue_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
