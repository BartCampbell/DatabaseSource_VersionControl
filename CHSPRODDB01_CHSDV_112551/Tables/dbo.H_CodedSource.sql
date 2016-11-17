CREATE TABLE [dbo].[H_CodedSource]
(
[H_CodedSource_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CodedSource_BK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientCodedSourceID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL CONSTRAINT [DF__H_CodedSo__LoadD__59904A2C] DEFAULT (getdate()),
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[H_CodedSource] ADD CONSTRAINT [PK_H_CodedSource] PRIMARY KEY CLUSTERED  ([H_CodedSource_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
