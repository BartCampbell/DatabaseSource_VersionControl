CREATE TABLE [dbo].[ProviderAddress]
(
[AddressSequence] [tinyint] NOT NULL,
[ProviderID] [int] NOT NULL,
[Client] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DataSource] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HedisMeasureID] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MailingAddress1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MailingAddress2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MailingCity] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MailingState] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MailingZipCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PracticeAddress1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PracticeAddress2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PracticeCity] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PracticeEmail] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PracticeFax] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PracticeName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PracticePhonePrimary] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PracticePhoneSecondary] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PracticeState] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PracticeZipCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProviderAddress] ADD CONSTRAINT [actProviderAddress_PK] PRIMARY KEY CLUSTERED  ([ProviderID], [AddressSequence]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProviderAddress] ADD CONSTRAINT [actProvider_ProviderAddress_FK1] FOREIGN KEY ([ProviderID]) REFERENCES [dbo].[Provider] ([ProviderID])
GO
ALTER TABLE [dbo].[ProviderAddress] ADD CONSTRAINT [FK_ProviderAddress_Provider] FOREIGN KEY ([ProviderID]) REFERENCES [dbo].[Provider] ([ProviderID]) ON DELETE CASCADE
GO
