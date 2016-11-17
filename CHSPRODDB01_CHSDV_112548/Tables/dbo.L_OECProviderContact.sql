CREATE TABLE [dbo].[L_OECProviderContact]
(
[L_OECProviderContact_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_OEC_RK] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_Provider_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_Contact_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_OECProviderContact] ADD CONSTRAINT [PK_L_ProviderContact] PRIMARY KEY CLUSTERED  ([L_OECProviderContact_RK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_OECProviderContact] ADD CONSTRAINT [FK_L_OECProviderContact_H_Contact] FOREIGN KEY ([H_Contact_RK]) REFERENCES [dbo].[H_Contact] ([H_Contact_RK])
GO
ALTER TABLE [dbo].[L_OECProviderContact] ADD CONSTRAINT [FK_L_OECProviderContact_H_OEC] FOREIGN KEY ([H_OEC_RK]) REFERENCES [dbo].[H_OEC] ([H_OEC_RK])
GO
ALTER TABLE [dbo].[L_OECProviderContact] ADD CONSTRAINT [FK_L_OECProviderContact_H_Provider] FOREIGN KEY ([H_Provider_RK]) REFERENCES [dbo].[H_Provider] ([H_Provider_RK])
GO
