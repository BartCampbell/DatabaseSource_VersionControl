CREATE TABLE [dbo].[dbo_ProviderContact_VIVA]
(
[ProviderContactID] [int] NOT NULL IDENTITY(1, 1),
[ProviderID] [int] NOT NULL,
[Phone] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fax] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AdvancePhone] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AdvanceFax] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreateDate] [datetime] NULL,
[LastUpdate] [datetime] NULL
) ON [PRIMARY]
GO
