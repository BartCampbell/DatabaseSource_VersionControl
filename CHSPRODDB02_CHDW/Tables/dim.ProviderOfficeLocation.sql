CREATE TABLE [dim].[ProviderOfficeLocation]
(
[ProviderOfficeLocationID] [int] NOT NULL IDENTITY(1, 1),
[ProviderOfficeID] [int] NOT NULL,
[Addr1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Addr2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[City] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Zip] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[County] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Advance_Addr1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Advance_Zip] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Advance_Phone] [varchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Advance_Fax] [varchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreateDate] [datetime] NULL CONSTRAINT [DF_ProviderOfficeLocation_CreateDate] DEFAULT (getdate()),
[LastUpdate] [datetime] NULL CONSTRAINT [DF_ProviderOfficeLocation_LastUpdate] DEFAULT (getdate()),
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dim].[ProviderOfficeLocation] ADD CONSTRAINT [PK_ProviderOfficeLocation] PRIMARY KEY CLUSTERED  ([ProviderOfficeLocationID]) ON [PRIMARY]
GO
ALTER TABLE [dim].[ProviderOfficeLocation] ADD CONSTRAINT [FK_ProviderOfficeLocation_ProviderOffice] FOREIGN KEY ([ProviderOfficeID]) REFERENCES [dim].[ProviderOffice] ([ProviderOfficeID])
GO
