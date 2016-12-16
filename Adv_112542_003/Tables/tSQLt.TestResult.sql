CREATE TABLE [tSQLt].[TestResult]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[Class] [nvarchar] (max) COLLATE SQL_Latin1_General_CP437_CI_AI NOT NULL,
[TestCase] [nvarchar] (max) COLLATE SQL_Latin1_General_CP437_CI_AI NOT NULL,
[Name] AS ((quotename([Class])+'.')+quotename([TestCase])),
[TranName] [nvarchar] (max) COLLATE SQL_Latin1_General_CP437_CI_AI NOT NULL,
[Result] [nvarchar] (max) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[Msg] [nvarchar] (max) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[TestStartTime] [datetime] NOT NULL CONSTRAINT [DF:TestResult(TestStartTime)] DEFAULT (getdate()),
[TestEndTime] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [tSQLt].[TestResult] ADD CONSTRAINT [PK__TestResu__3214EC07BB8C5B5A] PRIMARY KEY CLUSTERED  ([Id]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
