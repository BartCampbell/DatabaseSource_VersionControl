CREATE TABLE [adv].[tblUserZipCodeStage]
(
[User_PK] [int] NOT NULL,
[ZipCode_PK] [int] NOT NULL,
[Client] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL CONSTRAINT [DF__tblUserZi__LoadD__30E4D102] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [adv].[tblUserZipCodeStage] ADD CONSTRAINT [PK_tblUserZipCodeStage] PRIMARY KEY CLUSTERED  ([User_PK], [ZipCode_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
