CREATE TABLE [dbo].[H_Contract]
(
[H_Contract_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ContractNum_BK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[H_Contract] ADD CONSTRAINT [PK_H_Contract] PRIMARY KEY CLUSTERED  ([H_Contract_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
