CREATE TABLE [dbo].[tblChaseStatusLog]
(
[ChaseStatusLog_PK] [bigint] NOT NULL IDENTITY(1, 1),
[Suspect_PK] [bigint] NULL,
[From_ChaseStatus_PK] [int] NULL,
[To_ChaseStatus_PK] [int] NULL,
[User_PK] [int] NULL,
[dtUpdate] [date] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblChaseStatusLog] ADD CONSTRAINT [PK_tblChaseStatusLog] PRIMARY KEY CLUSTERED  ([ChaseStatusLog_PK]) ON [PRIMARY]
GO
