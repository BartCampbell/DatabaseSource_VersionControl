CREATE TABLE [dbo].[L_ClaimDataProvider]
(
[L_ClaimDataProvider_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_ClaimData_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_ProviderMaster_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_ClaimDataProvider] ADD CONSTRAINT [PK_L_ClaimDataProvider] PRIMARY KEY CLUSTERED  ([L_ClaimDataProvider_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_ClaimDataProvider] ADD CONSTRAINT [FK_H_ClaimData_RK2] FOREIGN KEY ([H_ClaimData_RK]) REFERENCES [dbo].[H_ClaimData] ([H_ClaimData_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[L_ClaimDataProvider] ADD CONSTRAINT [FK_H_ProviderMaster_RK6] FOREIGN KEY ([H_ProviderMaster_RK]) REFERENCES [dbo].[H_ProviderMaster] ([H_ProviderMaster_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
