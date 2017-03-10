SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jason Franks - jbfranks@gmail.com
-- Create date: 1/25/2014
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[prGetPrenatalMemberInfoByPursuitEventID] 
	-- Add the parameters for the stored procedure here
    @ID INT
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

        SELECT  pe.EventDate AS DeliveryDate ,
                ISNULL(NULLIF(NULLIF(LTRIM(RTRIM(ISNULL(mbr.NameLast, '')
                                                 + ISNULL(', ' + mbr.NameFirst,
                                                          '') + ISNULL(' '
                                                              + mbr.NameMiddleInitial,
                                                              ''))), ','), ''),
                       '(no name listed)') AS MemberName ,
                mbr.CustomerMemberID AS MemberID ,
                mbr.SSN ,
                mbr.DateOfBirth ,
                pe.PursuitEventID
        FROM    PursuitEvent pe
                INNER JOIN Pursuit pt ON pt.PursuitID = pe.PursuitID
                INNER JOIN Member mbr ON pt.MemberID = mbr.MemberID
                INNER JOIN Measure ms ON ms.MeasureID = pe.MeasureID
        WHERE   pe.PursuitEventID = @ID
                AND ms.HEDISMeasure = 'PPC' --ONLY PRENATAL

    END
GO
GRANT EXECUTE ON  [dbo].[prGetPrenatalMemberInfoByPursuitEventID] TO [ChartNet_AppUser_Custom]
GO
