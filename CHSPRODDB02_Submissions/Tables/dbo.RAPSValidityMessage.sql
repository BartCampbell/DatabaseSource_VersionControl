CREATE TABLE [dbo].[RAPSValidityMessage]
(
[HPlan] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClaimNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberID] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberHICN] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DOSFrom] [datetime] NULL,
[DOSTo] [datetime] NULL,
[DXCode] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ValidityCheck] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ValidityMessage] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProcessDate] [datetime] NULL,
[RAPSValidityMessageID] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RAPSValidityMessage] ADD CONSTRAINT [PK_RAPSValidityMessage] PRIMARY KEY CLUSTERED  ([RAPSValidityMessageID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
