CREATE TABLE [adv].[tblUserProjectStage]
(
[User_PK] [smallint] NOT NULL,
[Project_PK] [smallint] NOT NULL,
[Client] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL CONSTRAINT [DF__tblUserPr__LoadD__2B2BF7AC] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [adv].[tblUserProjectStage] ADD CONSTRAINT [PK_tblUserProjectStage] PRIMARY KEY CLUSTERED  ([User_PK], [Project_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
