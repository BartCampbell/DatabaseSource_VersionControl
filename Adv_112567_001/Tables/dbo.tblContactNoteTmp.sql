CREATE TABLE [dbo].[tblContactNoteTmp]
(
[ContactNote_PK] [smallint] NOT NULL IDENTITY(1, 1),
[ContactNote_Text] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsSystem] [bit] NULL,
[sortOrder] [smallint] NULL
) ON [PRIMARY]
GO
