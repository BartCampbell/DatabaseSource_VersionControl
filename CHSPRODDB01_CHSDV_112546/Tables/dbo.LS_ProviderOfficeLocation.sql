CREATE TABLE [dbo].[LS_ProviderOfficeLocation]
(
[LS_ProviderOfficeLocation_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NULL,
[L_ProviderOfficeLocation_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_ProviderOffice_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_Location_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Active] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LS_ProviderOfficeLocation] ADD CONSTRAINT [PK_LS_ProviderOfficeLocation] PRIMARY KEY CLUSTERED  ([LS_ProviderOfficeLocation_RK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20161004-151418] ON [dbo].[LS_ProviderOfficeLocation] ([HashDiff]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LS_ProviderOfficeLocation] ADD CONSTRAINT [FK_L_ProviderOfficeLocation_RK1] FOREIGN KEY ([L_ProviderOfficeLocation_RK]) REFERENCES [dbo].[L_ProviderOfficeLocation] ([L_ProviderOfficeLocation_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
