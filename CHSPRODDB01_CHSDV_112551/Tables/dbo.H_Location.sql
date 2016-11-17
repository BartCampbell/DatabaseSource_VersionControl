CREATE TABLE [dbo].[H_Location]
(
[H_Location_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Location_BK] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL CONSTRAINT [DF__H_Locatio__LoadD__1BFD2C07] DEFAULT (getdate()),
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[H_Location] ADD CONSTRAINT [PK_H_Location] PRIMARY KEY CLUSTERED  ([H_Location_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
