CREATE TABLE [dbo].[LS_ProviderMasterOffice]
(
[LS_ProviderMasterOffice_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NULL,
[L_ProviderMasterOffice_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Provider_PK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderOffice_PK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderMaster_PK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LS_ProviderMasterOffice] ADD CONSTRAINT [PK_LS_ProviderMasterOffice] PRIMARY KEY CLUSTERED  ([LS_ProviderMasterOffice_RK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LS_ProviderMasterOffice] ADD CONSTRAINT [FK_L_ProviderMasterOffice_RK1] FOREIGN KEY ([L_ProviderMasterOffice_RK]) REFERENCES [dbo].[L_ProviderMasterOffice] ([L_ProviderMasterOffice_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
