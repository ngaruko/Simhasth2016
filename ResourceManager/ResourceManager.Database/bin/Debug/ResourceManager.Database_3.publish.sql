﻿/*
Deployment script for ResourceManager

This code was generated by a tool.
Changes to this file may cause incorrect behavior and will be lost if
the code is regenerated.
*/

GO
SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, CONCAT_NULL_YIELDS_NULL, QUOTED_IDENTIFIER ON;

SET NUMERIC_ROUNDABORT OFF;


GO
:setvar DatabaseName "ResourceManager"
:setvar DefaultFilePrefix "ResourceManager"
:setvar DefaultDataPath ""
:setvar DefaultLogPath ""

GO
:on error exit
GO
/*
Detect SQLCMD mode and disable script execution if SQLCMD mode is not supported.
To re-enable the script after enabling SQLCMD mode, execute the following:
SET NOEXEC OFF; 
*/
:setvar __IsSqlCmdEnabled "True"
GO
IF N'$(__IsSqlCmdEnabled)' NOT LIKE N'True'
    BEGIN
        PRINT N'SQLCMD mode must be enabled to successfully execute this script.';
        SET NOEXEC ON;
    END


GO
USE [$(DatabaseName)];


GO
PRINT N'Creating [dbo].[Distance]...';


GO
create function dbo.Distance( @lat1 float , @long1 float , @lat2 float , @long2 float)
returns float

as

begin

declare @DegToRad as float
declare @Ans as float
declare @Miles as float

set @DegToRad = 57.29577951
set @Ans = 0
set @Miles = 0

if @lat1 is null or @lat1 = 0 or @long1 is null or @long1 = 0 or @lat2 is
null or @lat2 = 0 or @long2 is null or @long2 = 0

begin

return ( @Miles )

end

set @Ans = SIN(@lat1 / @DegToRad) * SIN(@lat2 / @DegToRad) + COS(@lat1 / @DegToRad ) * COS( @lat2 / @DegToRad ) * COS(ABS(@long2 - @long1 )/@DegToRad)

set @Miles = 3959 * ATAN(SQRT(1 - SQUARE(@Ans)) / @Ans)

set @Miles = CEILING(@Miles)

return ( @Miles * 1.60934 )

end
GO
PRINT N'Altering [dbo].[prc_GetNearByResources]...';


GO
ALTER PROCEDURE [dbo].[prc_GetNearByResources]
	@Lat float,
	@Long float,
	@radius float
AS
	select Id, Name, Phone, BloodGroup, Hierarchy, Reserve1, Lat, Long, LastUpdated,
		Distance(@Lat, @Long, Lat, Long) AS Distance
	from [ResourceManager].[Resource]
	where Distance(@Lat, @Long, Lat, Long) <= @radius
	Order By Distance
RETURN 0
GO
PRINT N'Update complete.';


GO
