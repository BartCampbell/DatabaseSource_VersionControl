CREATE TABLE [dbo].[Emblem_MemberDemo]
(
[RecordID] [int] NOT NULL IDENTITY(1, 1),
[MEM_START_DATE] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MEM_END_DATE] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CLIENTMEMBERID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MEM_LNAME] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MEM_FNAME] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MEM_DOB] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MEM_ADDR1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MEM_ADDR2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MEM_CITY] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MEM_COUNTY] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MEM_STATE] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MEM_ZIP] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Emblem_MemberDemo] ADD CONSTRAINT [PK__Emblem_M__FBDF78C9BD476E88] PRIMARY KEY CLUSTERED  ([RecordID]) ON [PRIMARY]
GO
