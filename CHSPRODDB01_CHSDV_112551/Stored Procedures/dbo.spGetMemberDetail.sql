SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 09/01/2016
-- Description:	Gets Member details from DV
-- =============================================
CREATE PROCEDURE [dbo].[spGetMemberDetail]
	-- Add the parameters for the stored procedure here
    @CCI VARCHAR(20) ,
    @LoadDate DATETIME
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

    -- Insert statements for procedure here

        SELECT  h.Member_BK AS CentauriMemberID ,
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
                s.recordSource AS RecordSource ,
                @CCI AS [ClientID] ,
                s.LoadDate AS LoadDate
        FROM    [dbo].[H_Member] h
                INNER JOIN dbo.S_MemberDetail s ON s.H_Member_RK = h.H_Member_RK
        WHERE   ( ISNULL(s.[Latitude], '') <> ''
                  OR ISNULL(s.[Longitude], '') <> ''
                  OR ISNULL(s.[parent_gardian], '') <> ''
                  OR ISNULL(s.[preferred_practitioner_gender], '') <> ''
                  OR ISNULL(s.[does_not_speak_english], '') <> ''
                  OR ISNULL(s.[unable_to_determine_language], '') <> ''
                  OR ISNULL(s.[speaking_language], '') <> ''
                  OR ISNULL(s.[language_line_will_be_required_for_the_visit],
                            '') <> ''
                  OR ISNULL(s.[plan_unable_to_validate_client_vendor_relationship],
                            '') <> ''
                  OR ISNULL(s.[preferred_method_of_contact], '') <> ''
                  OR ISNULL(s.[permission_to_leave_voicemail], '') <> ''
                  OR ISNULL(s.[place_of_assessment_is_not_members_home], '') <> ''
                  OR ISNULL(s.[members_power_of_attorney], '') <> ''
                  OR ISNULL(s.[POA_Name], '') <> ''
                )
                AND s.LoadDate > @LoadDate;

    END;
GO
