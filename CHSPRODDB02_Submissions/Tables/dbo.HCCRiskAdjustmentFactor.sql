CREATE TABLE [dbo].[HCCRiskAdjustmentFactor]
(
[HCCVersion] [int] NULL,
[HCCVersionYear] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CCType] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CC] [int] NULL,
[CCDescription] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Community] [decimal] (6, 3) NULL,
[Institutional] [decimal] (6, 3) NULL,
[CommunityNonDualAged] [decimal] (6, 3) NULL,
[CommunityNonDualDisabled] [decimal] (6, 3) NULL,
[CommunityFBDualAged] [decimal] (6, 3) NULL,
[CommunityFBDualDisabled] [decimal] (6, 3) NULL,
[CommunityPBDualAged] [decimal] (6, 3) NULL,
[CommunityPBDualDisabled] [decimal] (6, 3) NULL,
[HCCRiskAdjustmentFactorID] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[HCCRiskAdjustmentFactor] ADD CONSTRAINT [PK_HCCRiskAdjustmentFactor] PRIMARY KEY CLUSTERED  ([HCCRiskAdjustmentFactorID]) ON [PRIMARY]
GO
