CREATE TABLE [dbo].[S_CodedSourceDetail]
(
[S_CodedSourceDetail_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NULL,
[H_CodedSource_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CodedSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sortOrder] [smallint] NULL,
[HashDiff] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_CodedSourceDetail] ADD CONSTRAINT [PK_S_CodedSourceDetail] PRIMARY KEY CLUSTERED  ([S_CodedSourceDetail_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_CodedSourceDetail] ADD CONSTRAINT [FK_H_CodedSource_RK] FOREIGN KEY ([H_CodedSource_RK]) REFERENCES [dbo].[H_CodedSource] ([H_CodedSource_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
