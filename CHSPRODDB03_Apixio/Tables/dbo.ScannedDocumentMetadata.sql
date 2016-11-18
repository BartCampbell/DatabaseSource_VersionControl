CREATE TABLE [dbo].[ScannedDocumentMetadata]
(
[Pat_ID] [varchar] (30) COLLATE SQL_Latin1_General_CP437_CI_AI NOT NULL,
[Document_Type] [varchar] (10) COLLATE SQL_Latin1_General_CP437_CI_AI NOT NULL,
[Document_Title] [varchar] (50) COLLATE SQL_Latin1_General_CP437_CI_AI NOT NULL,
[File_Path_Name] [varchar] (200) COLLATE SQL_Latin1_General_CP437_CI_AI NOT NULL,
[From_Date] [varchar] (10) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[Thru_Date] [varchar] (10) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[Provider_ID] [varchar] (20) COLLATE SQL_Latin1_General_CP437_CI_AI NOT NULL,
[Chase_ID] [bigint] NOT NULL,
[Document_ID] [bigint] NOT NULL,
[Date_Refreshed] [datetime] NOT NULL,
[Date_Retreived] [datetime] NULL,
[RecID] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ScannedDocumentMetadata] ADD CONSTRAINT [PK_ScannedDocumentMetadata_RecID] PRIMARY KEY CLUSTERED  ([RecID]) ON [PRIMARY]
GO
