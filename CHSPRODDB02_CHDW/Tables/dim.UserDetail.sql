CREATE TABLE [dim].[UserDetail]
(
[UserDetailID] [int] NOT NULL IDENTITY(1, 1),
[UserID] [int] NULL,
[RemovedDate] [smalldatetime] NULL,
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
[ProviderID] [int] NULL,
[IsClient] [bit] NULL,
[IsSchedulerSV] [bit] NULL,
[IsScanTechSV] [bit] NULL,
[IsChangePasswordOnFirstLogin] [bit] NULL,
[isQCC] [bit] NULL,
[willing2travell] [smallint] NULL,
[linked_scheduler_user_pk] [int] NULL,
[EmploymentStatus] [tinyint] NULL,
[EmploymentAgency] [tinyint] NULL,
[isAllowDownload] [bit] NULL,
[RecordStartDate] [datetime] NULL CONSTRAINT [DF_UserDetail_RecordStartDate] DEFAULT (getdate()),
[RecordEndDate] [datetime] NULL CONSTRAINT [DF_UserDetail_RecordEndDate] DEFAULT ('2999-12-31'),
[CoderLevel] [tinyint] NULL,
[IsSchedulerManager] [bit] NULL,
[IsInvoiceAccountant] [bit] NULL,
[IsBillingAccountant] [bit] NULL,
[IsManagementUser] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dim].[UserDetail] ADD CONSTRAINT [PK_UserDetail] PRIMARY KEY CLUSTERED  ([UserDetailID]) ON [PRIMARY]
GO
ALTER TABLE [dim].[UserDetail] ADD CONSTRAINT [FK_UserDetail_Provider] FOREIGN KEY ([ProviderID]) REFERENCES [dim].[Provider] ([ProviderID])
GO
ALTER TABLE [dim].[UserDetail] ADD CONSTRAINT [FK_UserDetail_User] FOREIGN KEY ([UserID]) REFERENCES [dim].[User] ([UserID])
GO
