CREATE TABLE [Internal].[ClaimCodes]
(
[BatchID] [int] NOT NULL,
[ClaimTypeID] [tinyint] NULL,
[Code] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CodeID] [int] NULL,
[CodeTypeID] [tinyint] NOT NULL,
[DataRunID] [int] NOT NULL,
[DataSetID] [int] NOT NULL,
[DSClaimCodeID] [bigint] NOT NULL,
[DSClaimID] [bigint] NULL,
[DSClaimLineID] [bigint] NOT NULL,
[DSMemberID] [bigint] NULL,
[IsPrimary] [bit] NOT NULL CONSTRAINT [DF_Temp_ClaimCodes_IsPrimary] DEFAULT ((0)),
[SpId] [int] NOT NULL CONSTRAINT [DF_ClaimCodes_SpId] DEFAULT (@@spid)
) ON [PRIMARY]
GO
ALTER TABLE [Internal].[ClaimCodes] ADD CONSTRAINT [PK_Temp_ClaimCodes] PRIMARY KEY CLUSTERED  ([DSClaimCodeID], [SpId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Temp_ClaimCodes_DSClaimID] ON [Internal].[ClaimCodes] ([DSClaimID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Temp_ClaimCodes_CodeID] ON [Internal].[ClaimCodes] ([DSClaimLineID], [CodeID], [SpId]) ON [PRIMARY]
GO
