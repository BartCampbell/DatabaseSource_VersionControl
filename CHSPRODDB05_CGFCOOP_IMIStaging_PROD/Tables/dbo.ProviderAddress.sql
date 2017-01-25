CREATE TABLE [dbo].[ProviderAddress]
(
[ProviderAddressID] [int] NOT NULL IDENTITY(1, 1),
[ProviderID] [int] NOT NULL,
[Client] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DataSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HedisMeasureID] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MailingAddress1] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MailingAddress2] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MailingCity] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MailingState] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MailingZipCode] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PracticeAddress1] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PracticeAddress2] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PracticeCity] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PracticeEmail] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PracticeFax] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PracticeName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PracticePhonePrimary] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PracticePhoneSecondary] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PracticeState] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PracticeZipCode] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressSequenceNo] [int] NULL,
[AddressEffectiveDate] [datetime] NULL,
[AddressTermDate] [datetime] NULL,
[SourceSystem] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EntityID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
