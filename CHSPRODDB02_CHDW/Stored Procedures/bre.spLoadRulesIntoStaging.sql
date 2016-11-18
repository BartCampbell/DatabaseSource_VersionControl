SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





-- =============================================
-- Author:		Travis Parker
-- Create date:	08/04/2016
-- Description:	Loads the business rules into staging for the BRE
-- Usage:			
--		  EXECUTE bre.spLoadRulesIntoStaging
-- =============================================
CREATE PROC [bre].[spLoadRulesIntoStaging]
    @CallingProcess VARCHAR(50)
AS
    DECLARE @CurrentDate DATETIME = GETDATE();

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN
    
        TRUNCATE TABLE stage.BusinessRules;

        INSERT  INTO stage.BusinessRules
                ( ExecutionOrder ,
                  BusinessRule 
                )
                SELECT  r.ExecutionOrder ,
                        'INSERT INTO bre.RuleResults ( TargetColumnValue, BusinessKeyValue, BusinessRuleID, RecordSource, LoadDate )
					SELECT m.' + r.TargetColumnName + ' AS TargetColumnValue, m.' + s.BusinessKey + ' AS BusinessKeyValue, ' + CONVERT(VARCHAR(20), r.BusinessRuleID)
                        + ' AS BusinessRuleID, m.RecordSource, m.LoadDate FROM ' + s.Source + ' m LEFT JOIN bre.RuleResults r ON r.LoadDate = m.LoadDate
                                               AND r.RecordSource = m.RecordSource
                                               AND r.BusinessKeyValue = m.' + s.BusinessKey  + ' ' + r.ValidationExpression + ' AND ( ClientID = '
                        + CONVERT(VARCHAR(20), c.ClientID) + ') AND (r.RuleResultsID IS NULL);' AS BusinessRule
                FROM    ( SELECT    r1.* ,
                                    ROW_NUMBER() OVER ( ORDER BY r1.DataSourceID, ISNULL(NULLIF(r2.BusinessRuleID, 0), r1.BusinessRuleID), r1.ParentRuleID, r1.BusinessRuleID ) AS ExecutionOrder
                          FROM      bre.BusinessRule r1
                                    LEFT JOIN bre.BusinessRule r2 ON r1.ParentRuleID = r2.BusinessRuleID
                        ) r
                        INNER JOIN bre.DataSource s ON s.DataSourceID = r.DataSourceID
				    INNER JOIN bre.ClientRuleMapping c ON c.BusinessRuleID = r.BusinessRuleID AND c.Process = @CallingProcess

        SELECT  ExecutionOrder ,
                BusinessRule 
        FROM    stage.BusinessRules
	   ORDER BY ExecutionOrder;

    END;     

GO
