CREATE TABLE [dbo].[tblProviderOffice]
(
[ProviderOffice_PK] [bigint] NOT NULL IDENTITY(1, 1),
[Address] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ZipCode_PK] [int] NULL,
[ContactPerson] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ContactNumber] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FaxNumber] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
ALTER TABLE [dbo].[tblProviderOffice] ADD CONSTRAINT [PK_tblProviderOffice] PRIMARY KEY CLUSTERED  ([ProviderOffice_PK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idxPOAssignedUser_PK] ON [dbo].[tblProviderOffice] ([AssignedUser_PK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idxPOPoolPK] ON [dbo].[tblProviderOffice] ([Pool_PK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idxPOBucket] ON [dbo].[tblProviderOffice] ([ProviderOfficeBucket_PK]) ON [PRIMARY]
GO
CREATE STATISTICS [_dta_stat_533576939_2_3_1_12_13] ON [dbo].[tblProviderOffice] ([Address], [ZipCode_PK], [ProviderOffice_PK], [ProviderOfficeBucket_PK], [Pool_PK])
GO
CREATE STATISTICS [_dta_stat_533576939_12_13_14] ON [dbo].[tblProviderOffice] ([AssignedUser_PK], [ProviderOfficeBucket_PK], [Pool_PK])
GO
CREATE STATISTICS [_dta_stat_533576939_14_3_1_12] ON [dbo].[tblProviderOffice] ([AssignedUser_PK], [ZipCode_PK], [ProviderOffice_PK], [ProviderOfficeBucket_PK])
GO
CREATE STATISTICS [_dta_stat_533576939_13_3_1] ON [dbo].[tblProviderOffice] ([Pool_PK], [ZipCode_PK], [ProviderOffice_PK])
GO
CREATE STATISTICS [_dta_stat_533576939_1_14_12] ON [dbo].[tblProviderOffice] ([ProviderOffice_PK], [AssignedUser_PK], [ProviderOfficeBucket_PK])
GO
CREATE STATISTICS [_dta_stat_533576939_1_12_13_14_2] ON [dbo].[tblProviderOffice] ([ProviderOffice_PK], [ProviderOfficeBucket_PK], [Pool_PK], [AssignedUser_PK], [Address])
GO
CREATE STATISTICS [_dta_stat_533576939_12_3_14] ON [dbo].[tblProviderOffice] ([ProviderOfficeBucket_PK], [ZipCode_PK], [AssignedUser_PK])
GO
CREATE STATISTICS [_dta_stat_533576939_12_3_1_13_14_2] ON [dbo].[tblProviderOffice] ([ProviderOfficeBucket_PK], [ZipCode_PK], [ProviderOffice_PK], [Pool_PK], [AssignedUser_PK], [Address])
GO
CREATE STATISTICS [_dta_stat_533576939_3_1] ON [dbo].[tblProviderOffice] ([ZipCode_PK], [ProviderOffice_PK])
GO
