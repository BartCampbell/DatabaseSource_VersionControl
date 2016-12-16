CREATE TABLE [dbo].[H_Contact]
(
[H_Contact_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Contact_BK] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[H_Contact] ADD CONSTRAINT [PK_H_Phone] PRIMARY KEY CLUSTERED  ([H_Contact_RK]) ON [PRIMARY]
GO
