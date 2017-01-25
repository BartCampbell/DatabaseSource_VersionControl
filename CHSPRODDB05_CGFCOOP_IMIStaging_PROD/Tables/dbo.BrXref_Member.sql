CREATE TABLE [dbo].[BrXref_Member]
(
[BusRuleDtlID] [int] NOT NULL IDENTITY(1, 1),
[MemberID] [bigint] NULL,
[AlzheimersFlag] [bit] NULL,
[AssignedClinicAddress] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AssignedClinicFullName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AssignedClinicPhone] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AsthmaFlag] [bit] NULL,
[CADFlag] [bit] NULL,
[CancerFlag] [bit] NULL,
[ChronicPainFlag] [bit] NULL,
[CKDFlag] [bit] NULL,
[DepressionFlag] [bit] NULL,
[DHMPMediMediFlag] [bit] NULL,
[DHMPMediMediSource] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DiabetesFlag] [bit] NULL,
[FirstACSAdmitDOS] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GIDisordersFlag] [bit] NULL,
[HyperlipidemiaFlag] [bit] NULL,
[HypertensionFlag] [bit] NULL,
[LiverDiseaseFlag] [bit] NULL,
[MedClaimExpRank] [int] NULL,
[MemberColonoscopyFlag] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MethodOfTransportation] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OsteoporosisFlag] [bit] NULL,
[RheumatoidArthritisFlag] [bit] NULL,
[Top5DiseaseFlag] [bit] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idxMember] ON [dbo].[BrXref_Member] ([MemberID]) ON [NDX]
GO
CREATE STATISTICS [sp_idxMember] ON [dbo].[BrXref_Member] ([MemberID])
GO
