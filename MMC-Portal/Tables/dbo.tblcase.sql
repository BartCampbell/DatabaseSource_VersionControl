CREATE TABLE [dbo].[tblcase]
(
[case_pk] [bigint] NOT NULL IDENTITY(1, 1),
[member_pk] [int] NULL,
[Admit_Date] [date] NULL,
[Discharge_Date] [date] NULL,
[DOB] [date] NULL,
[case_status] [int] NULL,
[admit_time] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[discharg_time] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[admit_am] [int] NULL,
[discharg_am] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblcase] ADD CONSTRAINT [PK_tblcase] PRIMARY KEY CLUSTERED  ([case_pk]) ON [PRIMARY]
GO
