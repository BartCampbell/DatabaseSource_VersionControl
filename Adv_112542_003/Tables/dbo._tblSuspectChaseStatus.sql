CREATE TABLE [dbo].[_tblSuspectChaseStatus]
(
[Suspect_PK] [bigint] NOT NULL IDENTITY(1, 1),
[ChaseStatus_PK] [int] NULL,
[LastContacted] [smalldatetime] NULL,
[FollowUp] [smalldatetime] NULL
) ON [PRIMARY]
GO
