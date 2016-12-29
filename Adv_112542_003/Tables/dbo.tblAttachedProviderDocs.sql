CREATE TABLE [dbo].[tblAttachedProviderDocs]
(
[AttachedProviderDoc_PK] [int] NOT NULL IDENTITY(1, 1),
[attachedDocumentType_PK] [tinyint] NOT NULL,
[provider_User_PK] [int] NOT NULL,
[file_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[L1] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[L2] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[L3] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[attached_User_PK] [int] NOT NULL,
[attahed_date] [smalldatetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblAttachedProviderDocs] ADD CONSTRAINT [PK_tblAttachedProviderDocs] PRIMARY KEY CLUSTERED  ([AttachedProviderDoc_PK]) ON [PRIMARY]
GO
