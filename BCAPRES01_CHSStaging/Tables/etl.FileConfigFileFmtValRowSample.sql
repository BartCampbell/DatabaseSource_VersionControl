CREATE TABLE [etl].[FileConfigFileFmtValRowSample]
(
[FileConfigID] [int] NOT NULL,
[FileFmtValRowSample] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreateDate] [datetime] NOT NULL CONSTRAINT [DF__FileConfi__Creat__15F0184D] DEFAULT (getdate()),
[LastUpdated] [datetime] NOT NULL CONSTRAINT [DF__FileConfi__LastU__16E43C86] DEFAULT (getdate())
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [etl].[FileConfigFileFmtValRowSample] ADD CONSTRAINT [PK_FileConfigFileFmtValRowSample_FileConfigID] PRIMARY KEY CLUSTERED  ([FileConfigID]) ON [PRIMARY]
GO
