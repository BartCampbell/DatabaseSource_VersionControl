CREATE TABLE [dbo].[H_Claim]
(
[H_Claim_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Claim_BK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[H_Claim] ADD CONSTRAINT [PK_H_Claim] PRIMARY KEY CLUSTERED  ([H_Claim_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
