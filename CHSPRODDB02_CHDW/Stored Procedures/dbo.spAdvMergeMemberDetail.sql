SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:		Paul Johnson
-- Create date:	09/08/2016
-- Description:	merges the stage to dim for MemberDetail 
-- Usage:			
--		  EXECUTE dbo.spAdvMergeMemberDetail
-- =============================================
CREATE PROC [dbo].[spAdvMergeMemberDetail]
AS
    DECLARE @CurrentDate DATETIME = GETDATE();

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN
    


        INSERT  INTO [dim].[MemberDetail]
                ( [MemberID] ,
                  [Latitude] ,
                  [Longitude] ,
                  [parent_gardian] ,
                  [preferred_practitioner_gender] ,
                  [does_not_speak_english] ,
                  [unable_to_determine_language] ,
                  [speaking_language] ,
                  [language_line_will_be_required_for_the_visit] ,
                  [plan_unable_to_validate_client_vendor_relationship] ,
                  [preferred_method_of_contact] ,
                  [permission_to_leave_voicemail] ,
                  [place_of_assessment_is_not_members_home] ,
                  [members_power_of_attorney] ,
                  [POA_Name] ,
                  [RecordStartDate] ,
                  [RecordEndDate]
                )
                SELECT DISTINCT
                        m.MemberID ,
                        s.[Latitude] ,
                        s.[Longitude] ,
                        s.[parent_gardian] ,
                        s.[preferred_practitioner_gender] ,
                        s.[does_not_speak_english] ,
                        s.[unable_to_determine_language] ,
                        s.[speaking_language] ,
                        s.[language_line_will_be_required_for_the_visit] ,
                        s.[plan_unable_to_validate_client_vendor_relationship] ,
                        s.[preferred_method_of_contact] ,
                        s.[permission_to_leave_voicemail] ,
                        s.[place_of_assessment_is_not_members_home] ,
                        s.[members_power_of_attorney] ,
                        s.[POA_Name] ,
                        @CurrentDate ,
                        '2999-12-31 00:00:00.000'
                FROM    stage.MemberDetail_ADV s
                        INNER JOIN dim.Member m ON m.CentauriMemberID = s.CentauriMemberID
                        LEFT JOIN dim.MemberDetail d ON d.MemberID = m.MemberID
                                                        AND ISNULL(d.[Latitude],
                                                              0.00) = ISNULL(s.[Latitude],
                                                              0.00)
                                                        AND ISNULL(d.[Longitude],
                                                              0.00) = ISNULL(s.[Longitude],
                                                              0.00)
                                                        AND ISNULL(d.[parent_gardian],
                                                              '') = ISNULL(s.[parent_gardian],
                                                              '')
                                                        AND ISNULL(d.[preferred_practitioner_gender],
                                                              0) = ISNULL(s.[preferred_practitioner_gender],
                                                              0)
                                                        AND ISNULL(d.[does_not_speak_english],
                                                              0) = ISNULL(s.[does_not_speak_english],
                                                              0)
                                                        AND ISNULL(d.[unable_to_determine_language],
                                                              0) = ISNULL(s.[unable_to_determine_language],
                                                              0)
                                                        AND ISNULL(d.[speaking_language],
                                                              '') = ISNULL(s.[speaking_language],
                                                              '')
                                                        AND ISNULL(d.[language_line_will_be_required_for_the_visit],
                                                              0) = ISNULL(s.[language_line_will_be_required_for_the_visit],
                                                              0)
                                                        AND ISNULL(d.[plan_unable_to_validate_client_vendor_relationship],
                                                              0) = ISNULL(s.[plan_unable_to_validate_client_vendor_relationship],
                                                              0)
                                                        AND ISNULL(d.[preferred_method_of_contact],
                                                              0) = ISNULL(s.[preferred_method_of_contact],
                                                              0)
                                                        AND ISNULL(d.[permission_to_leave_voicemail],
                                                              0) = ISNULL(s.[permission_to_leave_voicemail],
                                                              0)
                                                        AND ISNULL(d.[place_of_assessment_is_not_members_home],
                                                              0) = ISNULL(s.[place_of_assessment_is_not_members_home],
                                                              0)
                                                        AND ISNULL(d.[members_power_of_attorney],
                                                              0) = ISNULL(s.[members_power_of_attorney],
                                                              0)
                                                        AND ISNULL(d.[POA_Name],
                                                              '') = ISNULL(s.[POA_Name],
                                                              '')
                WHERE   d.MemberDetailID IS NULL; 

		

        UPDATE  mc
        SET     mc.RecordEndDate = @CurrentDate
        FROM    stage.MemberDetail_ADV s
                INNER JOIN dim.Member m ON m.CentauriMemberID = s.CentauriMemberID
                INNER JOIN dim.MemberDetail mc ON mc.MemberID = m.MemberID
        WHERE   ( ISNULL(mc.[Latitude], 0.00) <> ISNULL(s.[Latitude], 0.00)
                  OR ISNULL(mc.[Longitude], 0.00) <> ISNULL(s.[Longitude],
                                                            0.00)
                  OR ISNULL(mc.[parent_gardian], '') <> ISNULL(s.[parent_gardian],
                                                              '')
                  OR ISNULL(mc.[preferred_practitioner_gender], 0) <> ISNULL(s.[preferred_practitioner_gender],
                                                              0)
                  OR ISNULL(mc.[does_not_speak_english], 0) <> ISNULL(s.[does_not_speak_english],
                                                              0)
                  OR ISNULL(mc.[unable_to_determine_language], 0) <> ISNULL(s.[unable_to_determine_language],
                                                              0)
                  OR ISNULL(mc.[speaking_language], '') <> ISNULL(s.[speaking_language],
                                                              '')
                  OR ISNULL(mc.[language_line_will_be_required_for_the_visit],
                            0) <> ISNULL(s.[language_line_will_be_required_for_the_visit],
                                         0)
                  OR ISNULL(mc.[plan_unable_to_validate_client_vendor_relationship],
                            0) <> ISNULL(s.[plan_unable_to_validate_client_vendor_relationship],
                                         0)
                  OR ISNULL(mc.[preferred_method_of_contact], 0) <> ISNULL(s.[preferred_method_of_contact],
                                                              0)
                  OR ISNULL(mc.[permission_to_leave_voicemail], 0) <> ISNULL(s.[permission_to_leave_voicemail],
                                                              0)
                  OR ISNULL(mc.[place_of_assessment_is_not_members_home], 0) <> ISNULL(s.[place_of_assessment_is_not_members_home],
                                                              0)
                  OR ISNULL(mc.[members_power_of_attorney], 0) <> ISNULL(s.[members_power_of_attorney],
                                                              0)
                  OR ISNULL(mc.[POA_Name], '') <> ISNULL(s.[POA_Name], '')
                )
                AND mc.RecordEndDate = '2999-12-31 00:00:00.000';

    END;     



GO
