CREATE TABLE [dbo].[H_100003_Member]
(
[H_Member_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Member_BK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SSN] [nchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[H_100003_Member] ADD CONSTRAINT [PK_H_100003_Member] PRIMARY KEY CLUSTERED  ([H_Member_RK]) ON [PRIMARY]
GO
