CREATE TABLE [dbo].[S_OECProject]
(
[S_OECProject_RK] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_OECProject_RK] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProjectID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProjectName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashDiff] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NOT NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_OECProject] ADD CONSTRAINT [PK_S_OECProject] PRIMARY KEY CLUSTERED  ([S_OECProject_RK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_OECProject] ADD CONSTRAINT [FK_S_OECProject_H_OECProject] FOREIGN KEY ([H_OECProject_RK]) REFERENCES [dbo].[H_OECProject] ([H_OECProject_RK])
GO
