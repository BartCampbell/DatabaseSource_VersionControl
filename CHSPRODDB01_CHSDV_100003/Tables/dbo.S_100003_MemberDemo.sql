CREATE TABLE [dbo].[S_100003_MemberDemo]
(
[MEM_START_DATE] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MEM_END_DATE] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientMemberID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MEMBER_QUAL] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERSON_ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MEM_GENDER] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MEM_SSN] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MEM_LNAME] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MEM_FNAME] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MEM_MNAME] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MEM_DOB] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MEM_DOD] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MEM_MEDICARE] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MEM_ADDR1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MEM_ADDR2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MEM_CITY] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MEM_COUNTY] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MEM_STATE] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MEM_ZIP] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MEM_EMAIL] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MEM_PHONE] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MEM_RACE] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MEM_ETHNICITY] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MEM_LANGUAGE] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MEM_DATA_SRC] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HIRE_DATE] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberHashKey] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientHashKey] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CMI] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CCI] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_100003_Member_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[S_100003_MemberDemo_RK] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_100003_MemberDemo] ADD CONSTRAINT [PK_S_100003_MemberDemo_work] PRIMARY KEY CLUSTERED  ([S_100003_MemberDemo_RK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_100003_MemberDemo] ADD CONSTRAINT [FK_S_100003_MemberDemo_work_H_100003_Member] FOREIGN KEY ([H_100003_Member_RK]) REFERENCES [dbo].[H_100003_Member] ([H_Member_RK])
GO
EXEC sp_addextendedproperty N'MS_Description', N'HASH(CMI:LoadDate:RecordSource)', 'SCHEMA', N'dbo', 'TABLE', N'S_100003_MemberDemo', 'COLUMN', N'S_100003_MemberDemo_RK'
GO
