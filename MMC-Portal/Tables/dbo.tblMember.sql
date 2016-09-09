CREATE TABLE [dbo].[tblMember]
(
[member_pk] [int] NOT NULL IDENTITY(1, 1),
[member_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[member_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DOB] [date] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblMember] ADD CONSTRAINT [PK_tblMember] PRIMARY KEY CLUSTERED  ([member_pk]) ON [PRIMARY]
GO
