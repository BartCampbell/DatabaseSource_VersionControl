SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 6/18/2015
-- Description:	Retreives the list of child objects associated with the parent's URL segment for the current customer and user.
-- =============================================
CREATE PROCEDURE [ReportPortal].[GetNavigation]
(
	@RptCustGuid uniqueidentifier = NULL,
	@RptCustID smallint = NULL,
	@RptObjGuid uniqueidentifier = NULL,
	@RptObjID smallint = NULL,
	@UrlSeg varchar(512) = NULL,
	@UserName varchar(128)
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @CustUrlSeg varchar(512);
	DECLARE @RptObjTypeID tinyint;

	--Attempt to identify the Object by its GUID, if the ID is unknown
	IF @RptObjID IS NULL AND 
		@RptObjGuid IS NOT NULL
	SELECT	@RptObjID = RptObjID
	FROM	ReportPortal.[Objects] AS RO WITH(NOLOCK)
	WHERE	(RO.RptObjGuid = @RptObjGuid);

	--Attempt to identify the Customer by its GUID, if the ID is unknown
	IF @RptCustID IS NULL AND
		@RptCustGuid IS NOT NULL
	SELECT	@RptCustID = RC.RptCustID
	FROM	ReportPortal.Customers AS RC WITH(NOLOCK)
	WHERE	(RC.RptCustGuid = @RptCustGuid);

	--Attempt to identify the Customer and Object by the potentially supplied combined URL segment.
	IF @RptCustID IS NULL OR
		@RptObjID IS NULL
	SELECT	@RptCustID = ISNULL(@RptCustID, RCOUS.RptCustID),
			@RptObjID = ISNULL(@RptObjID, RCOUS.RptObjID)
	FROM	ReportPortal.CustomerObjectUrlSegments AS RCOUS WITH(NOLOCK)
	WHERE	(RCOUS.UrlSeg = @UrlSeg);

	--Attempt to identify the Object by its URL segment, if still unknown
	IF @RptObjID IS NULL AND 
		@UrlSeg IS NOT NULL
	SELECT	@RptObjID = RptObjID
	FROM	ReportPortal.[Objects] AS RO WITH(NOLOCK)
	WHERE	(RO.UrlSeg = @UrlSeg);

	--Attempt to identify the Customer by its URL segment, if still unknown
	IF @RptCustID IS NULL AND 
		@UrlSeg IS NOT NULL
	SELECT	@RptCustID = RC.RptCustID,
			@CustUrlSeg = RC.UrlSeg
	FROM	ReportPortal.Customers AS RC WITH(NOLOCK)
	WHERE	(RC.UrlSeg = @UrlSeg);

	--Determine Customer's URL segment, if still unknown...
	IF @CustUrlSeg IS NULL
		SELECT	@CustUrlSeg = UrlSeg 
		FROM	ReportPortal.Customers AS RC WITH(NOLOCK)
		WHERE	(RptCustID = @RptCustID);

	--Determine Object's Type...
	SELECT	@RptObjTypeID = RptObjTypeID 
	FROM	ReportPortal.[Objects] AS RO WITH(NOLOCK)
	WHERE	(RO.RptObjID = @RptObjID);

	--Retrieve the navigation results
	WITH RootLevelObjects AS
	(
		SELECT DISTINCT
				RO.RptObjID
		FROM	ReportPortal.[Objects] AS RO WITH(NOLOCK)
				LEFT OUTER JOIN ReportPortal.Navigation AS RN WITH(NOLOCK)
						ON RN.ChildID = RO.RptObjID
		WHERE	(RN.ChildID IS NULL)
	),
	CategoryCounts AS
	(
		SELECT	COUNT(RN.ChildID) AS CountChildren, RN.RptObjID 
		FROM	ReportPortal.Navigation AS RN
				INNER JOIN ReportPortal.CustomerObjects AS RCO
						ON RCO.RptObjID = RN.ChildID
		WHERE	RCO.RptCustID = @RptCustID
		GROUP BY RN.RptObjID
	)
	SELECT	RO.Blurb,
			ISNULL(CC.CountChildren, 0) AS CountChildren,
            RO.Descr,
            RO.DisplayName,
            RO.ObjectName,
			RN.RptNavID,
            RO.RptObjGuid,
            RO.RptObjID,
            RO.RptObjTypeID,
            RO.RptRelPath,
            @CustUrlSeg + RO.UrlSeg AS UrlSeg
	FROM	ReportPortal.[Objects] AS RO WITH(NOLOCK)
			INNER JOIN ReportPortal.CustomerObjects AS RCO WITH(NOLOCK)
					ON RCO.RptObjID = RO.RptObjID
			CROSS APPLY ReportPortal.GetObjectPermissions(@UserName, @RptCustID) AS RGOP
			LEFT OUTER JOIN ReportPortal.Navigation AS RN WITH(NOLOCK)
					ON RN.ChildID = RO.RptObjID
			LEFT OUTER JOIN CategoryCounts AS CC
					ON CC.RptObjID = RO.RptObjID
	WHERE	(RCO.RptCustID = @RptCustID) AND
			(RGOP.RptCustObjID = RCO.RptCustObjID) AND
			(
				(
					(RN.RptObjID = @RptObjID)	
				) OR
				(
					--Return root-level objects if blank
					(@UrlSeg IN ('', '/', @CustUrlSeg)) AND
					(RO.RptObjID IN (SELECT t.RptObjID FROM RootLevelObjects AS t))
				) OR
				(
					--Return all reports if NULL (show all)
					(@UrlSeg IS NULL) AND
					(RO.RptObjTypeID = 2) AND
					(RN.RptNavID IS NOT NULL)
				)
			)
	ORDER BY RO.DisplayName;
END

GO
GRANT EXECUTE ON  [ReportPortal].[GetNavigation] TO [PortalApp]
GO
