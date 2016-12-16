CREATE TABLE [dbo].[tblProviderOffice]
(
[ProviderOffice_PK] [bigint] NOT NULL IDENTITY(1, 1),
[Address] [varchar] (250) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[ZipCode_PK] [int] NULL,
[ContactPerson] [varchar] (150) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[ContactNumber] [varchar] (120) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[FaxNumber] [varchar] (120) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[Email_Address] [varchar] (100) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[EMR_Type] [varchar] (50) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[EMR_Type_PK] [smallint] NULL,
[GroupName] [varchar] (100) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[LocationID] [varchar] (20) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[ProviderOfficeBucket_PK] [smallint] NULL,
[Pool_PK] [smallint] NULL,
[AssignedUser_PK] [smallint] NULL,
[AssignedDate] [smalldatetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblProviderOffice] ADD CONSTRAINT [PK_tblProviderOffice] PRIMARY KEY CLUSTERED  ([ProviderOffice_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idxPOAssignedUser_PK] ON [dbo].[tblProviderOffice] ([AssignedUser_PK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idxPOPoolPK] ON [dbo].[tblProviderOffice] ([Pool_PK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idxPOBucket] ON [dbo].[tblProviderOffice] ([ProviderOfficeBucket_PK]) ON [PRIMARY]
GO
