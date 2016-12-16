CREATE TABLE [dbo].[L_ProviderNetwork]
(
[L_ProviderNetwork_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_Provider_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_Network_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL CONSTRAINT [DF_L_ClientProvider_LoadDate] DEFAULT (getdate()),
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_ProviderNetwork] ADD CONSTRAINT [PK_L_ProviderNetwork] PRIMARY KEY CLUSTERED  ([L_ProviderNetwork_RK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_ProviderNetwork] ADD CONSTRAINT [FK_L_ProviderNetwork_H_Network] FOREIGN KEY ([H_Network_RK]) REFERENCES [dbo].[H_Network] ([H_Network_RK])
GO
ALTER TABLE [dbo].[L_ProviderNetwork] ADD CONSTRAINT [FK_L_ProviderNetwork_H_Provider] FOREIGN KEY ([H_Provider_RK]) REFERENCES [dbo].[H_Provider] ([H_Provider_RK])
GO
