CREATE TABLE [dbo].[CCAIClaimICDExtract]
(
[Claim_number] [int] NULL,
[Claim_ICD_number] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ICD Type] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ICD Line Number] [tinyint] NULL,
[HI_Position] [tinyint] NULL,
[ICD Sequence Number] [int] NOT NULL,
[PresentOnAdmission] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
