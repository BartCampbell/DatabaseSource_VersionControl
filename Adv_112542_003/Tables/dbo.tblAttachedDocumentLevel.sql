CREATE TABLE [dbo].[tblAttachedDocumentLevel]
(
[Level_PK] [tinyint] NOT NULL IDENTITY(1, 1),
[attachedDocumentType_PK] [tinyint] NULL,
[Level_Depth] [tinyint] NULL,
[Description] [varchar] (75) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblAttachedDocumentLevel] ADD CONSTRAINT [PK_tblAttachedDocumentLevel] PRIMARY KEY CLUSTERED  ([Level_PK]) ON [PRIMARY]
GO
