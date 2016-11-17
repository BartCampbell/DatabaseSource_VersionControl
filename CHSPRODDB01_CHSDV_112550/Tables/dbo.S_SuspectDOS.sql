CREATE TABLE [dbo].[S_SuspectDOS]
(
[S_SuspectDOS_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NULL,
[H_Suspect_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SuspectDOS_PK] [bigint] NOT NULL,
[DOS_From] [smalldatetime] NULL,
[DOS_To] [smalldatetime] NULL,
[HashDiff] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_SuspectDOS] ADD CONSTRAINT [PK_S_SuspectDOS] PRIMARY KEY CLUSTERED  ([S_SuspectDOS_RK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_SuspectDOS] ADD CONSTRAINT [FK_H_Suspect_RK10] FOREIGN KEY ([H_Suspect_RK]) REFERENCES [dbo].[H_Suspect] ([H_Suspect_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
