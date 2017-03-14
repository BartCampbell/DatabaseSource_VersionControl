CREATE TABLE [dbo].[L_ProviderApixioReturn]
(
[L_ProviderApixioReturn_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_Provider_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_ApixioReturn_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NOT NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_ProviderApixioReturn] ADD CONSTRAINT [PK_L_ProviderApixioReturn] PRIMARY KEY CLUSTERED  ([L_ProviderApixioReturn_RK]) ON [PRIMARY]
GO
