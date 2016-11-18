CREATE TABLE [dbo].[HCCLoadTableStaging]
(
[HCCVersion] [float] NULL,
[HCCVersionYear] [float] NULL,
[CCType] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CC] [float] NULL,
[Description Label ] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Community] [float] NULL,
[Institutional ] [float] NULL,
[CommunityNonDualAged] [float] NULL,
[CommunityNonDualDisabled] [float] NULL,
[CommunityFBDualAged] [float] NULL,
[CommunityFBDualDisabled] [float] NULL,
[CommunityPBDualAged] [float] NULL,
[CommunityPBDualDisabled] [float] NULL
) ON [PRIMARY]
GO
