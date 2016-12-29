CREATE TABLE [dbo].[tblCoderAssignment]
(
[Suspect_PK] [bigint] NOT NULL,
[User_PK] [smallint] NOT NULL,
[CoderLevel] [tinyint] NOT NULL,
[LastUpdated_User_PK] [smallint] NULL,
[LastUpdated_Date] [smalldatetime] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblCoderAssignmentLevel] ON [dbo].[tblCoderAssignment] ([CoderLevel]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblCoderAssignmentSuspect] ON [dbo].[tblCoderAssignment] ([Suspect_PK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblCoderAssignmentUser] ON [dbo].[tblCoderAssignment] ([User_PK]) ON [PRIMARY]
GO
