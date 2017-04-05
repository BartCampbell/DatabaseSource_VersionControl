CREATE TABLE [Claim].[Codes]
(
[Code] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CodeID] [int] NOT NULL IDENTITY(1, 1),
[CodeInfo] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CodeTypeID] [tinyint] NOT NULL,
[IsValid] [bit] NOT NULL CONSTRAINT [DF_Codes_IsValid] DEFAULT ((0))
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 6/20/2013
-- Description:	Populates the CodeInfo column of Claim.Codes and validates the codes
-- =============================================
CREATE TRIGGER [Claim].[Codes_PopulateCodeInfoAndValidate_IU] 
   ON  [Claim].[Codes]
   AFTER INSERT, UPDATE
AS 
BEGIN
	SET NOCOUNT ON;

	UPDATE	CC
	SET		CodeInfo = RTRIM(CCT.CodeType) + ' :: ' + LTRIM(RTRIM(CC.Code)),
			IsValid = CASE 
							WHEN NOT (CC.Code LIKE CCT.[ValidLike]) OR
								 NOT (LEN(CC.Code) BETWEEN CCT.ValidMinLength AND CCT.ValidMaxLength)
							THEN 0
							ELSE 1
							END
	FROM	Claim.Codes AS CC
			INNER JOIN Claim.CodeTypes AS CCT
					ON CC.CodeTypeID = CCT.CodeTypeID
			INNER JOIN INSERTED AS i
					ON CC.CodeID = i.CodeID
			LEFT OUTER JOIN DELETED AS d
					ON CC.CodeID = d.CodeID
	WHERE	--(1 = 1) OR
			(d.CodeID IS NULL) OR
			(i.Code <> d.Code) OR
			(i.CodeTypeID <> d.CodeTypeID);
			
END
GO
ALTER TABLE [Claim].[Codes] ADD CONSTRAINT [PK_Codes] PRIMARY KEY CLUSTERED  ([CodeID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Codes] ON [Claim].[Codes] ([Code], [CodeTypeID]) INCLUDE ([CodeID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Codes_CodeInfo] ON [Claim].[Codes] ([CodeInfo]) ON [PRIMARY]
GO
