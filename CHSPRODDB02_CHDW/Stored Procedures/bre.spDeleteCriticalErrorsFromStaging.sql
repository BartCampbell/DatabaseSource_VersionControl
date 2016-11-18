SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





-- =============================================
-- Author:		Travis Parker
-- Create date:	08/04/2016
-- Description:	deletes the records from staging that had critical errors in the BRE
-- Usage:			
--		  EXECUTE bre.spDeleteCriticalErrorsFromStaging
-- =============================================
CREATE PROC [bre].[spDeleteCriticalErrorsFromStaging]
    @LastLoadDate DATETIME
AS

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN
    
        DECLARE @SqlText NVARCHAR(MAX);
	   DECLARE @id INT ,
		  @BusinessKey VARCHAR(50) ,
		  @Source VARCHAR(50);

	   DECLARE @DataSources TABLE
		  (
		    id INT ,
		    BusinessKey VARCHAR(50) ,
		    Source VARCHAR(50)
		  ); 
	   INSERT  INTO @DataSources
			 ( id ,
			   BusinessKey ,
			   Source
			 )
			 SELECT  s.DataSourceID ,
				    s.BusinessKey ,
				    s.Source
			 FROM    bre.RuleResults r
				    INNER JOIN bre.BusinessRule b ON b.BusinessRuleID = r.BusinessRuleID
				    INNER JOIN bre.DataSource s ON s.DataSourceID = b.DataSourceID
			 WHERE   b.Severity < 5
				    AND r.ResultDate > @LastLoadDate
			 GROUP BY s.DataSourceID ,
				    s.BusinessKey ,
				    s.Source;


	   WHILE EXISTS ( SELECT   1
				   FROM     @DataSources )
		  BEGIN 

			 SELECT TOP 1
				    @id = id ,
				    @BusinessKey = BusinessKey ,
				    @Source = Source
			 FROM    @DataSources; 
    
			 SET @SqlText = N'DELETE FROM m 
					   FROM  bre.RuleResults r 
					   INNER JOIN bre.BusinessRule b ON b.BusinessRuleID = r.BusinessRuleID 
					   INNER JOIN bre.ClientRuleMapping c ON r.BusinessRuleID = c.BusinessRuleID AND c.Active = 1
					   INNER JOIN ' + @Source + ' m ON m.ClientID = c.ClientID AND m.LoadDate = r.LoadDate AND m.RecordSource = r.RecordSource AND m.'
					   + @BusinessKey + ' = r.BusinessKeyValue
					   WHERE b.Severity < 5  AND r.ResultDate > ''' + CONVERT(VARCHAR(20), @LastLoadDate, 120) + '''';


			 EXECUTE sp_executesql @SqlText;

			 DELETE  FROM @DataSources
			 WHERE   id = @id;

		  END;

    END;     





GO
