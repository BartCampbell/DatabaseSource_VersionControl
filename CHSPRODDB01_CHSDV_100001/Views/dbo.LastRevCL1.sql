SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[LastRevCL1]
AS
select *
from [dbo].[CL1] a
where RevisionId = (select max([RevisionId])
                    from [dbo].[CL1] b 
                    where a.InterchangeId = b.InterchangeId 
                      and a.PositionInInterchange = b.PositionInInterchange
                    )
GO
