CREATE TABLE [dbo].[MediAdv_RiskScoreCMSFactors]
(
[RecordID] [int] NOT NULL IDENTITY(1, 1),
[RAModelVersion] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Category] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DOSYr] [int] NULL,
[PmtYr] [int] NULL,
[NormalizationFactor] [decimal] (9, 3) NULL CONSTRAINT [DF__MediAdv_R__Norma__24134F1B] DEFAULT ((0.000)),
[CIFactor] [decimal] (9, 4) NULL CONSTRAINT [DF__MediAdv_R__CIFac__25077354] DEFAULT ((0.0000))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MediAdv_RiskScoreCMSFactors] ADD CONSTRAINT [UQ__MediAdv___FBDF78C80A5614D8] UNIQUE NONCLUSTERED  ([RecordID]) ON [PRIMARY]
GO
