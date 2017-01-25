CREATE TABLE [Ncqa].[PLD_Validations]
(
[Clause] [nvarchar] (512) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Descr] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ValidateGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_PLD_Validation_ValidateGuid] DEFAULT (newid()),
[ValidateID] [smallint] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [Ncqa].[PLD_Validations] ADD CONSTRAINT [PK_PLD_Validation] PRIMARY KEY CLUSTERED  ([ValidateID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_PLD_Validation_ValidateGuid] ON [Ncqa].[PLD_Validations] ([ValidateGuid]) ON [PRIMARY]
GO
