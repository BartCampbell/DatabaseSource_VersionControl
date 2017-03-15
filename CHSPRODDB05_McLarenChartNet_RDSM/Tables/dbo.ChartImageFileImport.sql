CREATE TABLE [dbo].[ChartImageFileImport]
(
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF__ChartImag__Creat__117F9D94] DEFAULT (getdate()),
[FileData] [varbinary] (max) NULL,
[FileID] [int] NOT NULL IDENTITY(1, 1),
[FileName] [nvarchar] (2048) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Name] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[NotifyDate] [datetime] NULL,
[OriginalPath] [nvarchar] (2048) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Path] [nvarchar] (2048) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Size] [bigint] NULL,
[Xref] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Ignore] [bit] NOT NULL CONSTRAINT [DF_ChartImageFileImport_Ignore] DEFAULT ((0)),
[ErrorEmailSent] [bit] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[ChartImageFileImport] ADD CONSTRAINT [PK_dbo_ChartImageFileImport] PRIMARY KEY CLUSTERED  ([FileID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_dbo_ChartImageFileImport] ON [dbo].[ChartImageFileImport] ([FileName]) ON [PRIMARY]
GO
