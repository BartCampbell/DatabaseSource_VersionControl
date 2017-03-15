CREATE TABLE [adv].[tblProviderOfficeScheduleHash]
(
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NULL CONSTRAINT [DF__tblProvid__Creat__5E975870] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [adv].[tblProviderOfficeScheduleHash] ADD CONSTRAINT [PK_tblProviderOfficeScheduleHash] PRIMARY KEY CLUSTERED  ([HashDiff]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
