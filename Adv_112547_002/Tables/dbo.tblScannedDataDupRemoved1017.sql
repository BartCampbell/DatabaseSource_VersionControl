CREATE TABLE [dbo].[tblScannedDataDupRemoved1017]
(
[ScannedData_PK] [bigint] NOT NULL,
[Suspect_PK] [bigint] NULL,
[DocumentType_PK] [tinyint] NULL,
[FileName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[User_PK] [smallint] NULL,
[dtInsert] [smalldatetime] NULL,
[is_deleted] [bit] NULL,
[CodedStatus] [tinyint] NULL
) ON [PRIMARY]
GO
