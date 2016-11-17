CREATE TABLE [dbo].[L_ProviderClaim]
(
[L_ProviderClaim_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_Provider_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_Claim_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_ProviderClaim] ADD CONSTRAINT [PK_L_ProviderClaim] PRIMARY KEY CLUSTERED  ([L_ProviderClaim_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_ProviderClaim] ADD CONSTRAINT [FK_L_ProviderClaim_H_Claim] FOREIGN KEY ([H_Claim_RK]) REFERENCES [dbo].[H_Claim] ([H_Claim_RK])
GO
ALTER TABLE [dbo].[L_ProviderClaim] ADD CONSTRAINT [FK_L_ProviderClaim_H_Provider] FOREIGN KEY ([H_Provider_RK]) REFERENCES [dbo].[H_Provider] ([H_Provider_RK])
GO
