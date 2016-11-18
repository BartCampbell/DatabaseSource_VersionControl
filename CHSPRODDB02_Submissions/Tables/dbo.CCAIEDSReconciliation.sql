CREATE TABLE [dbo].[CCAIEDSReconciliation]
(
[ClaimType] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClaimID] [int] NULL,
[DOS] [datetime] NULL,
[IsAccepted] [bit] NULL,
[IsRejected] [bit] NULL,
[IsAwaitingResponse] [bit] NULL,
[IsNotSubmitted] [bit] NULL,
[BabelRejectionReason] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RejectionReason999] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RejectionReason277] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RejectionReasonMAO] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PossibleSolution] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CCAIEDSReconciliationID] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[CCAIEDSReconciliation] ADD CONSTRAINT [PK_CCAIEDSReconciliation] PRIMARY KEY CLUSTERED  ([CCAIEDSReconciliationID]) ON [PRIMARY]
GO
