CREATE TABLE [dbo].[MemberAddress]
(
[MemberAddressID] [int] NOT NULL IDENTITY(1, 1),
[MemberID] [int] NOT NULL,
[Client] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DataSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MailingAddress1] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MailingAddress2] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MailingCity] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MailingState] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MailingZipCode] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressSequenceNo] [int] NULL,
[DateEffective] [datetime] NULL,
[DateTerminated] [datetime] NULL,
[CustomerAddressType] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerMemberAddressID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PhoneHome] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PhoneWork1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PhoneWork2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PhoneCell] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PhoneFax] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Email1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Email2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SourceSystem] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
