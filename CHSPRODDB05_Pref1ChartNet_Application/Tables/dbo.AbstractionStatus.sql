CREATE TABLE [dbo].[AbstractionStatus]
(
[AbstractionStatusID] [int] NOT NULL,
[Description] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsCompleted] [bit] NOT NULL CONSTRAINT [DF__Abstracti__IsCom__7E0DA1C4] DEFAULT ((0)),
[IsCopyMoveDefault] [bit] NOT NULL CONSTRAINT [DF_AbstractionStatus_IsCopyMoveDefault] DEFAULT ((0)),
[IsOmittedIRR] [bit] NOT NULL CONSTRAINT [DF_AbstractionStatus_IsOmittedRR] DEFAULT ((0)),
[IsOmittedReports] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AbstractionStatus] ADD CONSTRAINT [PK_AbstractionStatus] PRIMARY KEY CLUSTERED  ([AbstractionStatusID]) ON [PRIMARY]
GO
