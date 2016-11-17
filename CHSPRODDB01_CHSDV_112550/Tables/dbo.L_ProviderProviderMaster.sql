CREATE TABLE [dbo].[L_ProviderProviderMaster]
(
[L_ProviderProviderMaster_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_Provider_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_ProviderMaster_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_ProviderProviderMaster] ADD CONSTRAINT [PK_L_ProviderProviderMaster] PRIMARY KEY CLUSTERED  ([L_ProviderProviderMaster_RK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_ProviderProviderMaster] ADD CONSTRAINT [FK_H_Provider_RK8] FOREIGN KEY ([H_Provider_RK]) REFERENCES [dbo].[H_Provider] ([H_Provider_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[L_ProviderProviderMaster] ADD CONSTRAINT [FK_H_ProviderMaster_RK2] FOREIGN KEY ([H_ProviderMaster_RK]) REFERENCES [dbo].[H_ProviderMaster] ([H_ProviderMaster_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
