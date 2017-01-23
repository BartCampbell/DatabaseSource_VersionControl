CREATE TABLE [dbo].[MHHS_Recon_20170123]
(
[PDFname] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UploadDate] [datetime] NULL,
[Suspect_PK] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsDuplicate] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsCNA] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ChaseID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Project_Name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProjectGroup] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DataSource] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AssignedUser_PK] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AssignedDate] [datetime] NULL
) ON [PRIMARY]
GO
