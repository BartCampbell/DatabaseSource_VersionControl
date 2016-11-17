CREATE TABLE [dbo].[L_OECProviderLocation]
(
[L_OECProviderLocation_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_OEC_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_Provider_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_Location_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_OECProviderLocation] ADD CONSTRAINT [PK_L_ProviderLocation] PRIMARY KEY CLUSTERED  ([L_OECProviderLocation_RK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_OECProviderLocation] ADD CONSTRAINT [FK_L_OECProviderLocation_H_Location] FOREIGN KEY ([H_Location_RK]) REFERENCES [dbo].[H_Location] ([H_Location_RK])
GO
ALTER TABLE [dbo].[L_OECProviderLocation] ADD CONSTRAINT [FK_L_OECProviderLocation_H_OEC] FOREIGN KEY ([H_OEC_RK]) REFERENCES [dbo].[H_OEC] ([H_OEC_RK])
GO
ALTER TABLE [dbo].[L_OECProviderLocation] ADD CONSTRAINT [FK_L_OECProviderLocation_H_Provider] FOREIGN KEY ([H_Provider_RK]) REFERENCES [dbo].[H_Provider] ([H_Provider_RK])
GO
