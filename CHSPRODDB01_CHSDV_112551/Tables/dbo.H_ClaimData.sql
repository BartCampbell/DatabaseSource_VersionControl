CREATE TABLE [dbo].[H_ClaimData]
(
[H_ClaimData_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ClaimData_BK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientClaimDataID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL CONSTRAINT [DF__H_ClaimDa__LoadD__6225902D] DEFAULT (getdate()),
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[H_ClaimData] ADD CONSTRAINT [PK_H_ClaimData] PRIMARY KEY CLUSTERED  ([H_ClaimData_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
