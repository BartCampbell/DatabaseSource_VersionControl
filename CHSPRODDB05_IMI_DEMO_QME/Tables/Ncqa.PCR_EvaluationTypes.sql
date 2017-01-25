CREATE TABLE [Ncqa].[PCR_EvaluationTypes]
(
[Descr] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EvalTypeGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_PCR_EvaluationTypes_EvalTypeGuid] DEFAULT (newid()),
[EvalTypeID] [tinyint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Ncqa].[PCR_EvaluationTypes] ADD CONSTRAINT [PK_PCR_EvaluationTypes] PRIMARY KEY CLUSTERED  ([EvalTypeID]) ON [PRIMARY]
GO
