CREATE TABLE [etl].[FileLogDetail]
(
[FileLogDetailID] [int] NOT NULL IDENTITY(1000000, 1),
[FileLogID] [int] NOT NULL,
[FileLogDetailDate] [datetime] NOT NULL CONSTRAINT [df_FileLogDetail_FileLogDetailDate_01] DEFAULT (getdate()),
[FileLogDetailTxt] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [etl].[FileLogDetail] ADD CONSTRAINT [PK_FileLogDetail_FileLogDetailID_01] PRIMARY KEY CLUSTERED  ([FileLogDetailID]) ON [PRIMARY]
GO
