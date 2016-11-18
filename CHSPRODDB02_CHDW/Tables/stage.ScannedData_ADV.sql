CREATE TABLE [stage].[ScannedData_ADV]
(
[CentauriScannedDataID] [int] NOT NULL,
[CentauriSuspectID] [int] NULL,
[CentauriDocumentTypeID] [int] NULL,
[CentauriUserID] [int] NULL,
[FileName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dtInsert] [smalldatetime] NULL,
[is_deleted] [bit] NULL,
[CodedStatus] [tinyint] NULL,
[ClientID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL
) ON [PRIMARY]
GO
