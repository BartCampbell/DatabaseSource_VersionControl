SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Report].[GetChangeLog]
(
   @BeginLogDate SMALLDATETIME = NULL,
   @EndLogDate SMALLDATETIME = NULL
)
AS
    BEGIN

        SELECT  c.LogDate AS ChangeDate,
				ct.Descr AS ChangeType,
				c.Descr AS ChangeDescription
        FROM    Log.[Changes] c WITH(NOLOCK)
                JOIN Log.ChangeTypes ct  WITH(NOLOCK) ON c.ChngTypeID = ct.ChngTypeID
        WHERE   c.IsEnabled = 1
                AND ( @BeginLogDate IS NULL OR @BeginLogDate <= c.LogDate )
                AND ( @EndLogDate IS NULL OR c.LogDate <= @EndLogDate )
        ORDER BY c.LogDate DESC		

    END
GO
GRANT EXECUTE ON  [Report].[GetChangeLog] TO [Reporting]
GO
