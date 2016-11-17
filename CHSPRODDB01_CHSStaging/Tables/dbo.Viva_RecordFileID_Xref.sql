CREATE TABLE [dbo].[Viva_RecordFileID_Xref]
(
[RecordID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RTF_Name] [varchar] (24) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Viva_RecordFileID_Xref] ADD CONSTRAINT [PK_Viva_RecordFileID_Xref] PRIMARY KEY CLUSTERED  ([RecordID], [RTF_Name]) ON [PRIMARY]
GO
