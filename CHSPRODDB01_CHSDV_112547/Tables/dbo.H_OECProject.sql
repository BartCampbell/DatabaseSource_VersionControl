CREATE TABLE [dbo].[H_OECProject]
(
[H_OECProject_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OECProject_BK] [int] NOT NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NOT NULL CONSTRAINT [DF_H_OECProject_LoadDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[H_OECProject] ADD CONSTRAINT [PK_H_OECProject] PRIMARY KEY CLUSTERED  ([H_OECProject_RK]) ON [PRIMARY]
GO
