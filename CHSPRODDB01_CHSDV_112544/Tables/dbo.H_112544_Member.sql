CREATE TABLE [dbo].[H_112544_Member]
(
[H_112544_Member_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Member_BK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SSN] [nchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[H_112544_Member] ADD CONSTRAINT [PK__H_112544__154A48328E30B360] PRIMARY KEY CLUSTERED  ([H_112544_Member_RK]) ON [PRIMARY]
GO
