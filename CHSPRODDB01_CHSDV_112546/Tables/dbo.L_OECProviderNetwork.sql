CREATE TABLE [dbo].[L_OECProviderNetwork]
(
[L_OECProviderNetwork_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_OEC_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_Provider_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_Network_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL CONSTRAINT [DF_L_OECProviderNetwork_LoadDate] DEFAULT (getdate()),
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_OECProviderNetwork] ADD CONSTRAINT [PK_L_OECProviderNetwork] PRIMARY KEY CLUSTERED  ([L_OECProviderNetwork_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_OECProviderNetwork] ADD CONSTRAINT [FK_L_OECProviderNetwork_H_Network] FOREIGN KEY ([H_Network_RK]) REFERENCES [dbo].[H_Network] ([H_Network_RK])
GO
ALTER TABLE [dbo].[L_OECProviderNetwork] ADD CONSTRAINT [FK_L_OECProviderNetwork_H_OEC] FOREIGN KEY ([H_OEC_RK]) REFERENCES [dbo].[H_OEC] ([H_OEC_RK])
GO
ALTER TABLE [dbo].[L_OECProviderNetwork] ADD CONSTRAINT [FK_L_OECProviderNetwork_H_Provider] FOREIGN KEY ([H_Provider_RK]) REFERENCES [dbo].[H_Provider] ([H_Provider_RK])
GO
