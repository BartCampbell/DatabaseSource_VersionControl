CREATE TABLE [dbo].[L_ProviderType]
(
[L_ProviderType_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_Provider_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_Type_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_ProviderType] ADD CONSTRAINT [PK_L_ProviderType] PRIMARY KEY CLUSTERED  ([L_ProviderType_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_ProviderType] ADD CONSTRAINT [FK_L_ProviderType_H_Provider] FOREIGN KEY ([H_Provider_RK]) REFERENCES [dbo].[H_Provider] ([H_Provider_RK])
GO
ALTER TABLE [dbo].[L_ProviderType] ADD CONSTRAINT [FK_L_ProviderType_H_Type] FOREIGN KEY ([H_Type_RK]) REFERENCES [dbo].[H_Type] ([H_Type_RK])
GO
