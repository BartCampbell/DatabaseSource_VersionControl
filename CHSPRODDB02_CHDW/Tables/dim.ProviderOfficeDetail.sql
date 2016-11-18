CREATE TABLE [dim].[ProviderOfficeDetail]
(
[ProviderOfficeDetailID] [int] NOT NULL IDENTITY(1, 1),
[ProviderOfficeID] [int] NULL,
[EMR_Type] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EMR_Type_PK] [smallint] NULL,
[GroupName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordStartDate] [datetime] NULL CONSTRAINT [DF_ProviderOfficeDetail_RecordStartDate] DEFAULT (getdate()),
[RecordEndDate] [datetime] NULL CONSTRAINT [DF_ProviderOfficDetaile_RecordEndDate] DEFAULT ('2999-12-31'),
[LocationID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderOfficeBucket_PK] [smallint] NULL,
[Pool_PK] [smallint] NULL,
[AssignedUser_PK] [smallint] NULL,
[AssignedDate] [smalldatetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dim].[ProviderOfficeDetail] ADD CONSTRAINT [PK_ProviderOfficeDetail] PRIMARY KEY CLUSTERED  ([ProviderOfficeDetailID]) ON [PRIMARY]
GO
ALTER TABLE [dim].[ProviderOfficeDetail] ADD CONSTRAINT [FK_ProviderOfficeDetail_ProviderOffice] FOREIGN KEY ([ProviderOfficeID]) REFERENCES [dim].[ProviderOffice] ([ProviderOfficeID])
GO
