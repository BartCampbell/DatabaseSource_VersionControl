CREATE TABLE [etl].[FileLogDetail]
(
[FileLogDetailID] [int] NOT NULL IDENTITY(2000000, 1),
[FileLogID] [int] NOT NULL,
[FileLogDetailDate] [datetime] NOT NULL CONSTRAINT [DF_FileLogDetail_FileLogDetailDate] DEFAULT (getdate()),
[FileLogDetailTxt] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [etl].[FileLogDetail] ADD CONSTRAINT [PK_FileLogDetail_FileLogDetailID] PRIMARY KEY CLUSTERED  ([FileLogDetailID]) ON [PRIMARY]
GO
