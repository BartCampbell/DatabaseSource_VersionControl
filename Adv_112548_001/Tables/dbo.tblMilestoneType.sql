CREATE TABLE [dbo].[tblMilestoneType]
(
[MilestoneType_PK] [int] NOT NULL IDENTITY(1, 1),
[MilestoneType_Text] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblMilestoneType] ADD CONSTRAINT [PK_tblMsDetails] PRIMARY KEY CLUSTERED  ([MilestoneType_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
