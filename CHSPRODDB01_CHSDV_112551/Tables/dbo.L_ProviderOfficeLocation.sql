CREATE TABLE [dbo].[L_ProviderOfficeLocation]
(
[L_ProviderOfficeLocation_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_ProviderOffice_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_Location_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_ProviderOfficeLocation] ADD CONSTRAINT [PK_L_ProviderOfficeLocation] PRIMARY KEY CLUSTERED  ([L_ProviderOfficeLocation_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_ProviderOfficeLocation] ADD CONSTRAINT [FK_H_Location_RK4] FOREIGN KEY ([H_Location_RK]) REFERENCES [dbo].[H_Location] ([H_Location_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[L_ProviderOfficeLocation] ADD CONSTRAINT [FK_H_ProviderOffice_RK1] FOREIGN KEY ([H_ProviderOffice_RK]) REFERENCES [dbo].[H_ProviderOffice] ([H_ProviderOffice_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
