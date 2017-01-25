CREATE TABLE [dbo].[FaxLogDocument]
(
[FaxLogDocID] [smallint] NOT NULL,
[Description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ReportName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DropFolder] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FaxLogDocument] ADD CONSTRAINT [PK_FaxLogDocument] PRIMARY KEY CLUSTERED  ([FaxLogDocID]) ON [PRIMARY]
GO
