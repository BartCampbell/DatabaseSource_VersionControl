CREATE TABLE [dbo].[S_MOR_Trailer]
(
[S_MOR_Trailer_RK] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_MOR_Header_RK] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RecordTypeCode] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ContractNumber] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TotalRecordCount] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashDiff] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_MOR_Trailer] ADD CONSTRAINT [PK_S_MOR_Trailer] PRIMARY KEY CLUSTERED  ([S_MOR_Trailer_RK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_MOR_Trailer] ADD CONSTRAINT [FK_S_MOR_Trailer_H_MOR_Header] FOREIGN KEY ([H_MOR_Header_RK]) REFERENCES [dbo].[H_MOR_Header] ([H_MOR_Header_RK])
GO
