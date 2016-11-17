CREATE TABLE [dbo].[H_ProviderOffice]
(
[H_ProviderOffice_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProviderOffice_BK] [int] NULL,
[ClientProviderOfficeID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL CONSTRAINT [DF__H_Provide__LoadD__382F5661] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[H_ProviderOffice] ADD CONSTRAINT [PK_H_ProviderOffice] PRIMARY KEY CLUSTERED  ([H_ProviderOffice_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
