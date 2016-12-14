CREATE TABLE [dbo].[Provider]
(
[ProviderID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProviderName] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Provider] ADD CONSTRAINT [PK_Provider] PRIMARY KEY CLUSTERED  ([ProviderID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
