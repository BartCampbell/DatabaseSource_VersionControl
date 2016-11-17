CREATE TABLE [dbo].[LS_ProviderOfficeContact]
(
[LS_ProviderOfficeContact_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NULL,
[L_ProviderOfficeContact_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_ProviderOffice_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_Contact_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Active] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LS_ProviderOfficeContact] ADD CONSTRAINT [PK_LS_ProviderOfficeContact] PRIMARY KEY CLUSTERED  ([LS_ProviderOfficeContact_RK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20161004-151404] ON [dbo].[LS_ProviderOfficeContact] ([HashDiff]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LS_ProviderOfficeContact] ADD CONSTRAINT [FK_L_ProviderOfficeContact_RK1] FOREIGN KEY ([L_ProviderOfficeContact_RK]) REFERENCES [dbo].[L_ProviderOfficeContact] ([L_ProviderOfficeContact_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
