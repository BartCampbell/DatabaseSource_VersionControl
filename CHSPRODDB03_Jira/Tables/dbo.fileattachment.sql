CREATE TABLE [dbo].[fileattachment]
(
[ID] [numeric] (18, 0) NOT NULL,
[issueid] [numeric] (18, 0) NULL,
[MIMETYPE] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[FILENAME] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[CREATED] [datetime] NULL,
[FILESIZE] [numeric] (18, 0) NULL,
[AUTHOR] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[zip] [int] NULL,
[thumbnailable] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[fileattachment] ADD CONSTRAINT [PK_fileattachment] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [attach_issue] ON [dbo].[fileattachment] ([issueid]) ON [PRIMARY]
GO
