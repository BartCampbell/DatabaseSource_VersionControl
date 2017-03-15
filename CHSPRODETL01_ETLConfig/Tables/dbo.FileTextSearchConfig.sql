CREATE TABLE [dbo].[FileTextSearchConfig]
(
[FileTextSearchID] [int] NOT NULL IDENTITY(1, 1),
[FTPConfigID] [int] NOT NULL,
[FileTextSearchString] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FileTextSearchDestPath] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FileTextSearchArchPath] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsActive] [bit] NULL CONSTRAINT [DF_FileTextSearchConfig_IsActive] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FileTextSearchConfig] ADD CONSTRAINT [PK_FileSearchConfig] PRIMARY KEY CLUSTERED  ([FileTextSearchID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FileTextSearchConfig] ADD CONSTRAINT [FK_FileSearchConfig_FTPConfig] FOREIGN KEY ([FTPConfigID]) REFERENCES [dbo].[FTPConfig] ([FTPConfigID])
GO
