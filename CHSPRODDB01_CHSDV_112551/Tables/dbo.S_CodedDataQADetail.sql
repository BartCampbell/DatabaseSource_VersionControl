CREATE TABLE [dbo].[S_CodedDataQADetail]
(
[S_CodedDataQADetail_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NULL,
[H_CodedData_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsConfirmed] [bit] NULL,
[IsRemoved] [bit] NULL,
[Old_ICD9] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Old_CPT] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dtInsert] [smalldatetime] NULL,
[QA_User_PK] [int] NULL,
[IsAdded] [bit] NULL,
[IsChanged] [bit] NULL,
[HashDiff] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_CodedDataQADetail] ADD CONSTRAINT [PK_S_CodedDataQADetail] PRIMARY KEY CLUSTERED  ([S_CodedDataQADetail_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_CodedDataQADetail] ADD CONSTRAINT [FK_H_CodedData_RK9] FOREIGN KEY ([H_CodedData_RK]) REFERENCES [dbo].[H_CodedData] ([H_CodedData_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
