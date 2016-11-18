CREATE TABLE [dbo].[CCAIInstitutionalReconStaging]
(
[Claim Id] [float] NULL,
[DOS] [datetime] NULL,
[Accepted] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Rejected] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Awaiting Response] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Not Submitted] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Babel Rejection Reason] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[999 Rejection Reason] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[277 Rejection Reason] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MAO Rejection Reason] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Possible Resolution] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
