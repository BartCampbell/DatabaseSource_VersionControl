CREATE TABLE [adv].[tblScheduleTypeHash]
(
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NULL CONSTRAINT [DF__tblSchedu__Creat__766EE201] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [adv].[tblScheduleTypeHash] ADD CONSTRAINT [PK_tblScheduleTypeHash] PRIMARY KEY CLUSTERED  ([HashDiff]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
