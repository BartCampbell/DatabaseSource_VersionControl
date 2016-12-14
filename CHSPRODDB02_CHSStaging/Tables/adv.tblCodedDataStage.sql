CREATE TABLE [adv].[tblCodedDataStage]
(
[CodedData_PK] [bigint] NOT NULL,
[Suspect_PK] [bigint] NOT NULL,
[DiagnosisCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DOS_From] [smalldatetime] NULL,
[DOS_Thru] [smalldatetime] NULL,
[CPT] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Provider_PK] [bigint] NULL,
[CodedSource_PK] [smallint] NULL,
[IsICD10] [bit] NULL,
[Coded_User_PK] [smallint] NULL,
[Coded_Date] [smalldatetime] NULL,
[Updated_Date] [smalldatetime] NULL,
[OpenedPage] [smallint] NULL,
[Is_Deleted] [bit] NULL,
[ScannedData_PK] [bigint] NULL,
[Client] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL CONSTRAINT [DF__tblCodedD__LoadD__061A6E8E] DEFAULT (getdate()),
[CCI] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CodedDataHashKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientHashKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CDI] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [adv].[tblCodedDataStage] ADD CONSTRAINT [PK_tblCodedDataStage] PRIMARY KEY CLUSTERED  ([CodedData_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
