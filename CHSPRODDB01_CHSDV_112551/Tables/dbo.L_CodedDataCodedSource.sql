CREATE TABLE [dbo].[L_CodedDataCodedSource]
(
[L_CodedDataCodedSource_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_CodedData_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_CodedSource_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_CodedDataCodedSource] ADD CONSTRAINT [PK_L_CodedDataCodedSource] PRIMARY KEY CLUSTERED  ([L_CodedDataCodedSource_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_CodedDataCodedSource] ADD CONSTRAINT [FK_H_CodedData_RK5] FOREIGN KEY ([H_CodedData_RK]) REFERENCES [dbo].[H_CodedData] ([H_CodedData_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[L_CodedDataCodedSource] ADD CONSTRAINT [FK_H_CodedSource_RK2] FOREIGN KEY ([H_CodedSource_RK]) REFERENCES [dbo].[H_CodedSource] ([H_CodedSource_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
