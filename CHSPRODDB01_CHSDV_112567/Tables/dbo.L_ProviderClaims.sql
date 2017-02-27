CREATE TABLE [dbo].[L_ProviderClaims]
(
[L_ProviderClaims_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_Provider_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_Claims_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_ProviderClaims] ADD CONSTRAINT [PK_L_ProviderClaims] PRIMARY KEY CLUSTERED  ([L_ProviderClaims_RK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_ProviderClaims] ADD CONSTRAINT [FK_ProviderClaims_H_Claims_RK] FOREIGN KEY ([H_Claims_RK]) REFERENCES [dbo].[H_Claims] ([H_Claims_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[L_ProviderClaims] ADD CONSTRAINT [FK_ProviderClaims_H_Provider_RK] FOREIGN KEY ([H_Provider_RK]) REFERENCES [dbo].[H_Provider] ([H_Provider_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
