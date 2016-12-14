CREATE TABLE [dbo].[Viva_WorkRecords]
(
[RecordID] [int] NOT NULL,
[FileText] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FileID] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MemberID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Viva_WorkRecords] ADD CONSTRAINT [PK_Viva_WorkRecords] PRIMARY KEY CLUSTERED  ([RecordID]) ON [PRIMARY]
GO
