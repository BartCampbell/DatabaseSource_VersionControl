CREATE TABLE [dbo].[L_ProviderHEDIS]
(
[L_ProviderHEDIS_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_Provider_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_HEDIS_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NOT NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_ProviderHEDIS] ADD CONSTRAINT [PK_L_ProviderHEDIS] PRIMARY KEY CLUSTERED  ([L_ProviderHEDIS_RK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_ProviderHEDIS] ADD CONSTRAINT [FK_L_ProviderHEDIS_H_HEDIS] FOREIGN KEY ([H_HEDIS_RK]) REFERENCES [dbo].[H_HEDIS] ([H_HEDIS_RK])
GO
ALTER TABLE [dbo].[L_ProviderHEDIS] ADD CONSTRAINT [FK_L_ProviderHEDIS_H_Provider] FOREIGN KEY ([H_Provider_RK]) REFERENCES [dbo].[H_Provider] ([H_Provider_RK])
GO
