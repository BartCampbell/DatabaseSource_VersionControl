CREATE TABLE [dbo].[tblCodedData_bk]
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
[CoderLevel] [tinyint] NULL
) ON [PRIMARY]
GO
