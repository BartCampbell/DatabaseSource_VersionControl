CREATE TABLE [dbo].[S_AdvanceLocationDetail]
(
[S_AdvanceLocationDetail_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NULL,
[H_AdvanceLocation_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Location] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashDiff] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_AdvanceLocationDetail] ADD CONSTRAINT [PK_S_AdvanceLocationDetail] PRIMARY KEY CLUSTERED  ([S_AdvanceLocationDetail_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_AdvanceLocationDetail] ADD CONSTRAINT [FK_H_AdvanceLocation_RK1] FOREIGN KEY ([H_AdvanceLocation_RK]) REFERENCES [dbo].[H_AdvanceLocation] ([H_AdvanceLocation_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
