CREATE TABLE [dbo].[H_Member]
(
[H_Member_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Member_BK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientMemberID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL CONSTRAINT [DF__H_Member__LoadDa__1367E606] DEFAULT (getdate()),
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[H_Member] ADD CONSTRAINT [PK_H_Member] PRIMARY KEY CLUSTERED  ([H_Member_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
