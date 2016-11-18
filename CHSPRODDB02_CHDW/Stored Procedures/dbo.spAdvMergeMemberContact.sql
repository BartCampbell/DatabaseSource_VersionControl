SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Paul Johnson
-- Create date:	09/08/2016
-- Description:	merges the stage to dim for MemberContact based on sp834MergeMemberContact
-- Usage:			
--		  EXECUTE dbo.spAdvMergeMemberContact
-- =============================================
CREATE PROCEDURE [dbo].[spAdvMergeMemberContact]
AS
    DECLARE @CurrentDate DATETIME = GETDATE();

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN
    
        INSERT  INTO dim.MemberContact
                ( MemberID ,
                  Phone ,
                  Cell ,
                  EmailAddress ,
                  ContactType ,
                  RecordStartDate ,
                  RecordEndDate
	            )
                SELECT DISTINCT
                        m.MemberID ,
                        s.Phone ,
                        s.Cell ,
                        s.EmailAddress ,
                        s.ContactType ,
                        @CurrentDate ,
                        '2999-12-31 00:00:00.000'
                FROM    stage.MemberContact_ADV s
                        INNER JOIN dim.Member m ON m.CentauriMemberID = s.CentauriMemberID
                        LEFT JOIN dim.MemberContact d ON d.MemberID = m.MemberID
                                                         AND ISNULL(d.Phone,
                                                              '') = ISNULL(s.Phone,
                                                              '')
                                                         AND ISNULL(d.Cell, '') = ISNULL(s.Cell,
                                                              '')
                                                         AND ISNULL(d.EmailAddress,
                                                              '') = ISNULL(s.EmailAddress,
                                                              '')
                                                         AND ISNULL(d.ContactType,
                                                              '') = ISNULL(s.ContactType,
                                                              '')
                WHERE   d.MemberContactID IS NULL; 

        UPDATE  mc
        SET     mc.RecordEndDate = @CurrentDate
        FROM    stage.MemberContact_ADV s
                INNER JOIN dim.Member m ON m.CentauriMemberID = s.CentauriMemberID
                INNER JOIN dim.MemberContact mc ON mc.MemberID = m.MemberID AND ISNULL(mc.ContactType, '') = ISNULL(s.ContactType, '')
        WHERE   ( ISNULL(mc.Phone, '') <> ISNULL(s.Phone, '')
                  OR ISNULL(mc.Cell, '') <> ISNULL(s.Cell, '')
                  OR ISNULL(mc.EmailAddress, '') <> ISNULL(s.EmailAddress, '')
                        )
                AND mc.RecordEndDate = '2999-12-31 00:00:00.000';

    END;     


GO
