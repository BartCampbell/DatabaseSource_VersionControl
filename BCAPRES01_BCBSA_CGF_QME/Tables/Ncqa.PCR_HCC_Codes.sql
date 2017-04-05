CREATE TABLE [Ncqa].[PCR_HCC_Codes]
(
[Code] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CodeID] [int] NULL,
[CodeTypeID] [tinyint] NOT NULL,
[IsAcute] [bit] NOT NULL CONSTRAINT [DF_PCR_HCC_Codes_IsAcute] DEFAULT ((0)),
[IsInpatient] [bit] NOT NULL CONSTRAINT [DF_PCR_HCC_Codes_IsInpatient] DEFAULT ((0)),
[IsSurg] [bit] NOT NULL CONSTRAINT [DF_PCR_HCC_Codes_IsSurg] DEFAULT ((0)),
[MeasureSetID] [int] NOT NULL,
[PcrBID] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [Ncqa].[PCR_HCC_Codes] ADD CONSTRAINT [PK_PCR_HCC_Codes] PRIMARY KEY CLUSTERED  ([PcrBID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PCR_HCC_Codes] ON [Ncqa].[PCR_HCC_Codes] ([MeasureSetID], [CodeTypeID]) INCLUDE ([Code], [IsAcute], [IsInpatient], [IsSurg]) ON [PRIMARY]
GO
