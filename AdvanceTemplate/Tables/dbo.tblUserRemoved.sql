CREATE TABLE [dbo].[tblUserRemoved]
(
[RemovedBy_User_PK] [int] NOT NULL,
[Removed_date] [smalldatetime] NULL,
[User_PK] [int] NOT NULL,
[Username] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Password] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lastname] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Firstname] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Email_Address] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsSuperUser] [bit] NULL,
[IsAdmin] [bit] NULL,
[IsScanTech] [bit] NULL,
[IsScheduler] [bit] NULL,
[IsReviewer] [bit] NULL,
[IsQA] [bit] NULL,
[IsActive] [bit] NULL,
[only_work_selected_hours] [bit] NULL,
[only_work_selected_zipcodes] [bit] NULL,
[deactivate_after] [smalldatetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblUserRemoved] ADD CONSTRAINT [PK_tblUserRemoved] PRIMARY KEY CLUSTERED  ([User_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
