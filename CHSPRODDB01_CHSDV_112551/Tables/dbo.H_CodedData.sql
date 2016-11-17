CREATE TABLE [dbo].[H_CodedData]
(
[H_CodedData_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CodedData_BK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientCodedDataID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL CONSTRAINT [DF__H_CodedDa__LoadD__725BF7F6] DEFAULT (getdate()),
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[H_CodedData] ADD CONSTRAINT [PK_H_CodedData] PRIMARY KEY CLUSTERED  ([H_CodedData_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
