CREATE TABLE [dbo].[H_Project]
(
[H_Project_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Project_BK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientProjectID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[H_Project] ADD CONSTRAINT [PK_H_Project] PRIMARY KEY CLUSTERED  ([H_Project_RK]) ON [PRIMARY]
GO
