CREATE TABLE [dim].[ProviderOfficeContact]
(
[ProviderOfficeContactID] [int] NOT NULL IDENTITY(1, 1),
[ProviderOfficeID] [int] NOT NULL,
[Phone] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fax] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AdvancePhone] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AdvanceFax] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreateDate] [datetime] NULL CONSTRAINT [DF_ProviderOfficeContact_CreateDate] DEFAULT (getdate()),
[LastUpdate] [datetime] NULL CONSTRAINT [DF_ProviderOfficeContact_LastUpdate] DEFAULT (getdate()),
[EmailAddress] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dim].[ProviderOfficeContact] ADD CONSTRAINT [PK_ProviderOfficeContact] PRIMARY KEY CLUSTERED  ([ProviderOfficeContactID]) ON [PRIMARY]
GO
ALTER TABLE [dim].[ProviderOfficeContact] ADD CONSTRAINT [FK_ProviderContact_ProviderOffice] FOREIGN KEY ([ProviderOfficeID]) REFERENCES [dim].[ProviderOffice] ([ProviderOfficeID])
GO
