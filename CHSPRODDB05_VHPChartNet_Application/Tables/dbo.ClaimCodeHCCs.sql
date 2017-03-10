CREATE TABLE [dbo].[ClaimCodeHCCs]
(
[Code] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CodeTypeID] [smallint] NOT NULL,
[Description] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HCC] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HCCDescription] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RiskYear] [smallint] NOT NULL,
[HasHCC] AS (CONVERT([bit],case  when [HCC] IS NOT NULL AND [HCC]<>'' then (1) else (0) end,(0)))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ClaimCodeHCCs] ADD CONSTRAINT [PK_ClaimCodeHCCs] PRIMARY KEY CLUSTERED  ([Code], [CodeTypeID], [HCC], [RiskYear]) ON [PRIMARY]
GO
