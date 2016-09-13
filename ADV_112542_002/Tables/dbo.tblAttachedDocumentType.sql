CREATE TABLE [dbo].[tblAttachedDocumentType]
(
[attachedDocumentType_PK] [tinyint] NOT NULL,
[attachedDocumentType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Level1_Desc] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Level1_Type] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Level2_Desc] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Level2_Type] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Level3_Desc] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Level3_Type] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[isQCC] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblAttachedDocumentType] ADD CONSTRAINT [PK_tblAttachedDocumentType] PRIMARY KEY CLUSTERED  ([attachedDocumentType_PK]) ON [PRIMARY]
GO
