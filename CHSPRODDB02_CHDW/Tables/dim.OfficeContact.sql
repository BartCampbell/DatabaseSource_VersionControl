CREATE TABLE [dim].[OfficeContact]
(
[OfficeContactID] [int] NOT NULL IDENTITY(1, 1),
[Phone] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fax] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AdvancePhone] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AdvanceFax] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreateDate] [datetime] NULL CONSTRAINT [DF_OfficeContact_CreateDate] DEFAULT (getdate()),
[LastUpdate] [datetime] NULL CONSTRAINT [DF_OfficeContact_LastUpdate] DEFAULT (getdate()),
[EmailAddress] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dim].[OfficeContact] ADD CONSTRAINT [PK_OfficeContact] PRIMARY KEY CLUSTERED  ([OfficeContactID]) ON [PRIMARY]
GO
