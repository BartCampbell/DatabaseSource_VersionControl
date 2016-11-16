CREATE TABLE [dbo].[tblMemberLockStatus]
(
[Member_PK] [bigint] NOT NULL,
[User_PK] [int] NULL,
[lockDate] [smalldatetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblMemberLockStatus] ADD CONSTRAINT [PK_tblMemberLockStatus] PRIMARY KEY CLUSTERED  ([Member_PK]) ON [PRIMARY]
GO
