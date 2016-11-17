CREATE TABLE [adv].[tblUserWorkingHourStage]
(
[User_PK] [int] NOT NULL,
[Day_PK] [tinyint] NOT NULL,
[FromHour] [tinyint] NULL,
[FromMin] [tinyint] NULL,
[ToHour] [tinyint] NULL,
[ToMin] [tinyint] NULL,
[Client] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL CONSTRAINT [DF__tblUserWo__LoadD__2FF0ACC9] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [adv].[tblUserWorkingHourStage] ADD CONSTRAINT [PK_tblUserWorkingHourStage] PRIMARY KEY CLUSTERED  ([User_PK], [Day_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
