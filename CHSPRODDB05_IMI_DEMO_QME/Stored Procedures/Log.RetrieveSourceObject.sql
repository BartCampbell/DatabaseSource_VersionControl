SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 8/27/2012
-- Description:	Retrieves the source object identifiers for the specified object, creating one if it does not already exist.
-- =============================================
CREATE PROCEDURE [Log].[RetrieveSourceObject]
(
	@ObjectName nvarchar(128),
	@ObjectSchema nvarchar(128),
	@SrcObjectGuid uniqueidentifier = NULL OUTPUT,
	@SrcObjectID smallint = NULL OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT	@SrcObjectGuid = SO.SrcObjectGuid,
			@SrcObjectID = SO.SrcObjectID 
	FROM	[Log].SourceObjects AS SO
	WHERE	(ObjectName = @ObjectName) AND
			(ObjectSchema = @ObjectSchema);
	
	IF @SrcObjectID IS NULL
		BEGIN;
			SET @SrcObjectGuid = NEWID();
			
			INSERT INTO	[Log].SourceObjects
			        (SrcObjectGuid,
					ObjectName,
					ObjectSchema)
			 VALUES	(@SrcObjectGuid,
					@ObjectName,
					@ObjectSchema);
			 						        
			 SET @SrcObjectID = SCOPE_IDENTITY();
		END;
END

GO
GRANT VIEW DEFINITION ON  [Log].[RetrieveSourceObject] TO [db_executer]
GO
GRANT EXECUTE ON  [Log].[RetrieveSourceObject] TO [db_executer]
GO
GRANT EXECUTE ON  [Log].[RetrieveSourceObject] TO [Processor]
GO
GRANT EXECUTE ON  [Log].[RetrieveSourceObject] TO [Submitter]
GO
