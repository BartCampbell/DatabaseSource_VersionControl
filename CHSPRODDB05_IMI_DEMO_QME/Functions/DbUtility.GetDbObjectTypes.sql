SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 1/21/2013
-- Description:	Returns database objects and types, as well as their system type and DbUtility type.
-- =============================================
CREATE FUNCTION [DbUtility].[GetDbObjectTypes] 
(	
	@ObjectSchema nvarchar(128) = NULL,
	@ObjectName nvarchar(128) = NULL
)
RETURNS TABLE 
AS
RETURN 
(
	WITH DbObjects AS
	(
		SELECT	o.name AS ObjectName,
				s.name AS ObjectSchema,
				o.type COLLATE DATABASE_DEFAULT AS SysObjectType
		FROM	sys.objects AS o
				INNER JOIN sys.schemas AS s
						ON o.schema_id = s.schema_id
		WHERE	o.type <> 'SN'
		UNION
		SELECT	t.name AS ObjectName,
				s.name AS ObjectSchema,
				CONVERT(char(2), CASE t.is_table_type WHEN 1 THEN '?T' WHEN 0 THEN '?' END) AS SysObjectType
		FROM	sys.types AS t
				INNER JOIN sys.schemas AS s
						ON t.schema_id = s.schema_id
		WHERE	t.is_user_defined = 1
	),
	DbObjectTypeIDs AS
	(
		SELECT	t.ObjectName,
		        t.ObjectSchema,
		        SDOT.ObjectTypeID,
		        t.SysObjectType
		FROM	DbObjects AS t	
				INNER JOIN DbUtility.SplitDbObjectTypes AS SDOT
						ON t.SysObjectType = SDOT.SysObjectType
	)
	SELECT	*
	FROM	DbObjectTypeIDs
	WHERE	((@ObjectName IS NULL) OR (ObjectName = @ObjectName)) AND
			((@ObjectSchema IS NULL) OR (ObjectSchema = @ObjectSchema))

)
GO
