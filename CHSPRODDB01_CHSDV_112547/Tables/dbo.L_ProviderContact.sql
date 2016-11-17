CREATE TABLE [dbo].[L_ProviderContact]
(
[L_ProviderContact_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_Provider_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_Contact_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_ProviderContact] ADD CONSTRAINT [PK_L_ProviderContact1] PRIMARY KEY CLUSTERED  ([L_ProviderContact_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_ProviderContact] ADD CONSTRAINT [FK_H_Contact_RK2] FOREIGN KEY ([H_Contact_RK]) REFERENCES [dbo].[H_Contact] ([H_Contact_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[L_ProviderContact] ADD CONSTRAINT [FK_H_Provider_RK] FOREIGN KEY ([H_Provider_RK]) REFERENCES [dbo].[H_Provider] ([H_Provider_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
