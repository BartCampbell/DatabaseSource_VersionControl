CREATE TABLE [dbo].[S_UserDetails]
(
[S_UserDetails_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NULL,
[Password] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RemovedDate] [smalldatetime] NULL,
[IsSuperUser] [bit] NULL,
[IsAdmin] [bit] NULL,
[IsScanTech] [bit] NULL,
[IsScheduler] [bit] NULL,
[IsReviewer] [bit] NULL,
[IsQA] [bit] NULL,
[IsHRA] [bit] NULL,
[IsActive] [bit] NULL,
[only_work_selected_hours] [bit] NULL,
[only_work_selected_zipcodes] [bit] NULL,
[deactivate_after] [smalldatetime] NULL,
[linked_provider_id] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[linked_provider_pk] [bigint] NULL,
[IsClient] [bit] NULL,
[IsSchedulerSV] [bit] NULL,
[IsScanTechSV] [bit] NULL,
[IsChangePasswordOnFirstLogin] [bit] NULL,
[Location_PK] [tinyint] NULL,
[isQCC] [bit] NULL,
[willing2travell] [smallint] NULL,
[Latitude] [float] NULL,
[Longitude] [float] NULL,
[linked_scheduler_user_pk] [int] NULL,
[EmploymentStatus] [tinyint] NULL,
[EmploymentAgency] [tinyint] NULL,
[isAllowDownload] [bit] NULL,
[CoderLevel] [tinyint] NULL,
[IsSchedulerManager] [bit] NULL,
[IsInvoiceAccountant] [bit] NULL,
[IsBillingAccountant] [bit] NULL,
[IsManagementUser] [bit] NULL,
[H_User_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashDiff] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL,
[IsCoderOnsite] [bit] NULL,
[IsCoderOffsite] [bit] NULL,
[ISQACoder] [bit] NULL,
[IsQAManager] [int] NULL,
[IsCodingManager] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_UserDetails] ADD CONSTRAINT [PK_S_UserDetails] PRIMARY KEY CLUSTERED  ([S_UserDetails_RK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20161003-081957] ON [dbo].[S_UserDetails] ([HashDiff]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_UserDetails] ADD CONSTRAINT [FK_H_User_RK4] FOREIGN KEY ([H_User_RK]) REFERENCES [dbo].[H_User] ([H_User_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
