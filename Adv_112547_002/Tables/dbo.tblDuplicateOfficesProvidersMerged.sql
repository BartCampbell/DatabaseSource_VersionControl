CREATE TABLE [dbo].[tblDuplicateOfficesProvidersMerged]
(
[ProviderOffice_PK] [bigint] NOT NULL IDENTITY(1, 1),
[Address] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ZipCode_PK] [int] NULL,
[ContactPerson] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ContactNumber] [varchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FaxNumber] [varchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Email_Address] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EMR_Type] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EMR_Type_PK] [smallint] NULL,
[GroupName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LocationID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderOfficeBucket_PK] [smallint] NULL,
[Pool_PK] [smallint] NULL,
[AssignedUser_PK] [smallint] NULL,
[AssignedDate] [smalldatetime] NULL
) ON [PRIMARY]
GO
