CREATE TABLE [dbo].[tblCodedDataQA]
(
[CodedData_PK] [bigint] NULL,
[IsConfirmed] [bit] NULL,
[IsRemoved] [bit] NULL,
[Old_ICD9] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Old_CPT] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dtInsert] [smalldatetime] NULL,
[QA_User_PK] [int] NULL,
[IsAdded] [bit] NULL,
[IsChanged] [bit] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_CodeData_PK] ON [dbo].[tblCodedDataQA] ([CodedData_PK]) INCLUDE ([IsAdded], [IsChanged], [IsConfirmed], [IsRemoved]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
