CREATE TABLE [dbo].[L_ProviderLocation]
(
[L_ProviderLocation_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_Provider_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_Location_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_ProviderLocation] ADD CONSTRAINT [PK_L_ProviderLocation] PRIMARY KEY CLUSTERED  ([L_ProviderLocation_RK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_ProviderLocation] ADD CONSTRAINT [FK_L_ProviderLocation_H_Location] FOREIGN KEY ([H_Location_RK]) REFERENCES [dbo].[H_Location] ([H_Location_RK])
GO
ALTER TABLE [dbo].[L_ProviderLocation] ADD CONSTRAINT [FK_L_ProviderLocation_H_Provider] FOREIGN KEY ([H_Provider_RK]) REFERENCES [dbo].[H_Provider] ([H_Provider_RK])
GO
