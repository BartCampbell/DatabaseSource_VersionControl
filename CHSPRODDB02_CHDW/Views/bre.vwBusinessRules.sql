SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*
    Author: Travis Parker
    Date:	  08/25/2016
    Desc:	  view of bre rules
*/

CREATE VIEW [bre].[vwBusinessRules]
AS
    SELECT  r.BusinessRuleID ,
            d.Source ,
            d.BusinessKey ,
            r.TargetColumnName ,
            r.AllowNullValue ,
            r.ValidationExpression ,
            r.ErrorMessage ,
            r.Severity ,
            t.RuleType ,
            r.ParentRuleID
    FROM    bre.DataSource d
            INNER JOIN bre.BusinessRule r ON r.DataSourceID = d.DataSourceID
            INNER JOIN bre.RuleType t ON t.RuleTypeID = r.RuleTypeID;

GO
