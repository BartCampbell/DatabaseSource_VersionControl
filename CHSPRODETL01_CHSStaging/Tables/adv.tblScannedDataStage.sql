CREATE TABLE [adv].[tblScannedDataStage]
(
[ScannedData_PK] [bigint] NOT NULL,
[Suspect_PK] [bigint] NULL,
[DocumentType_PK] [tinyint] NULL,
[FileName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[User_PK] [smallint] NULL,
[dtInsert] [smalldatetime] NULL,
[is_deleted] [bit] NULL CONSTRAINT [DF__tblScanne__is_de__4C77DCDE] DEFAULT ((0)),
[CodedStatus] [tinyint] NULL,
[Client] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL CONSTRAINT [DF__tblScanne__LoadD__5418FEA6] DEFAULT (getdate()),
[CCI] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ScannedDataHashKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CSI] [int] NULL,
[ClientHashKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [adv].[tblScannedDataStage] ADD CONSTRAINT [PK_tblScannedDataStage] PRIMARY KEY CLUSTERED  ([ScannedData_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
