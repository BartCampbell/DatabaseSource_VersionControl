CREATE TABLE [dbo].[S_ClaimDataDetail]
(
[S_ClaimDataDetail_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NULL,
[H_ClaimData_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DiagnosisCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DOS_From] [smalldatetime] NULL,
[DOS_Thru] [smalldatetime] NULL,
[CPT] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsICD10] [bit] NULL,
[Claim_ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashDiff] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_ClaimDataDetail] ADD CONSTRAINT [PK_S_ClaimDataDetail] PRIMARY KEY CLUSTERED  ([S_ClaimDataDetail_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_ClaimDataDetail] ADD CONSTRAINT [FK_H_ClaimData_RK] FOREIGN KEY ([H_ClaimData_RK]) REFERENCES [dbo].[H_ClaimData] ([H_ClaimData_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
