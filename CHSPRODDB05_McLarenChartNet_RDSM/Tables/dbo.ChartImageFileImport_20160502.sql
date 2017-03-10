CREATE TABLE [dbo].[ChartImageFileImport_20160502]
(
[CreatedDate] [datetime] NOT NULL,
[FileData] [varbinary] (max) NULL,
[FileID] [int] NOT NULL IDENTITY(1, 1),
[FileName] [nvarchar] (2048) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Name] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[NotifyDate] [datetime] NULL,
[OriginalPath] [nvarchar] (2048) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Path] [nvarchar] (2048) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Size] [bigint] NULL,
[Xref] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Ignore] [bit] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
