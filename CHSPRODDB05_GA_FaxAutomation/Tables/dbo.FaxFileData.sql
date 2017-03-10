CREATE TABLE [dbo].[FaxFileData]
(
[Data] [varbinary] (max) NOT NULL,
[FaxFileID] [int] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[FaxFileData] ADD CONSTRAINT [PK_FaxFileData] PRIMARY KEY CLUSTERED  ([FaxFileID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FaxFileData] ADD CONSTRAINT [FK_FaxFileData_FaxFiles] FOREIGN KEY ([FaxFileID]) REFERENCES [dbo].[FaxFiles] ([FaxFileID])
GO
