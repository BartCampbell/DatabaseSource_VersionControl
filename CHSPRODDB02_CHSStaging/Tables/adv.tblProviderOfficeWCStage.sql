CREATE TABLE [adv].[tblProviderOfficeWCStage]
(
[ProviderOffice_PK] [bigint] NOT NULL,
[Address] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ZipCode_PK] [int] NULL,
[ContactPerson] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ContactNumber] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FaxNumber] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Email_Address] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EMR_Type] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EMR_Type_PK] [smallint] NULL,
[GroupName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LocationID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderOfficeBucket_PK] [smallint] NULL,
[Pool_PK] [smallint] NULL,
[AssignedUser_PK] [smallint] NULL,
[AssignedDate] [smalldatetime] NULL,
[Client] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[CCI] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderOfficeHashKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientHashKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CPI] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [adv].[tblProviderOfficeWCStage] ADD CONSTRAINT [PK_tblProviderOfficeWCStage] PRIMARY KEY CLUSTERED  ([ProviderOffice_PK]) ON [PRIMARY]
GO
