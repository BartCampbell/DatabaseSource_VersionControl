CREATE TABLE [adv].[tblUserPageStage]
(
[User_PK] [smallint] NOT NULL,
[Page_PK] [smallint] NOT NULL,
[Client] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL CONSTRAINT [DF__tblUserPa__LoadD__2943AF3A] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [adv].[tblUserPageStage] ADD CONSTRAINT [PK_tblUserPageStage] PRIMARY KEY CLUSTERED  ([User_PK], [Page_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
