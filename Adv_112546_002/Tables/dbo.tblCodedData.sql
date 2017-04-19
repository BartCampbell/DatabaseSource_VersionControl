CREATE TABLE [dbo].[tblCodedData]
(
[CodedData_PK] [bigint] NOT NULL IDENTITY(1, 1),
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
[CoderLevel] [tinyint] NULL,
[BeforeQA_OpenedPage] [smallint] NULL,
[BeforeQA_ScannedData_PK] [bigint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblCodedData] ADD CONSTRAINT [PK_tblCodedData] PRIMARY KEY CLUSTERED  ([CodedData_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_CodeData_PK] ON [dbo].[tblCodedData] ([CodedData_PK]) INCLUDE ([DiagnosisCode], [DOS_Thru]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblCodedDataSource] ON [dbo].[tblCodedData] ([CodedSource_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblCodedDataICD9] ON [dbo].[tblCodedData] ([DiagnosisCode]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblCodedDataProvider] ON [dbo].[tblCodedData] ([Provider_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblCodedDataSuspect] ON [dbo].[tblCodedData] ([Suspect_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
