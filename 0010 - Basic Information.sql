/*============================================================================
	File:		        0010 - Basic Information

	Description:	    This script obtain the first granular information about
                        the current system like
                        - Version + CU's
                        - Memory
                        - CPU
                        - Threads

	Date:		        January 2024

	SQL Server Version: all versions since SQL 2005
------------------------------------------------------------------------------
	Written by Uwe Ricken, db Berater GmbH

	This script is intended only as a supplement to demos and lectures
	given by Uwe Ricken.  
  
	THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
	ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
	TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
	PARTICULAR PURPOSE.
============================================================================*/

/*
	Servicepack list: https://sqlserverbuilds.blogspot.com/
*/
SELECT	SERVERPROPERTY('Collation')						        AS	[SQL Server Collation],
		SERVERPROPERTY('Edition')						        AS	[SQL Server Edition],
		SERVERPROPERTY('ComputerNamePhysicalNetBIOS')	        AS	[SQL Server MachineName],
		SERVERPROPERTY('InstanceName')					        AS	[SQL Server Instance],
		SERVERPROPERTY('IsClustered')					        AS	[SQL Server Clustered],
		SERVERPROPERTY('ProductVersion')				        AS	[SQL Server Version],
        CAST(N'https://sqlserverbuilds.blogspot.com/' AS XML)   AS  [actual_versions],
		SERVERPROPERTY('ProductLevel')					        AS	[SQL Server Version Level];
GO

-- What traceflags are enabled in the sql server environment
-- TF 1118:	uses UNIFORM EXTENTS (8 Pages = 1 Extent)
-- TF 1117: all Files grow at the same time
-- TF 2371:	statistics update threshold will decrease >=25.000
-- SQL SERVER >= 2026 (SP1) don't need the above TF!
DBCC TRACESTATUS (-1);
GO

-- SQL Server Services information (from SQL Server 2008 R2 (SP3) onward ONLY)
SELECT	servicename								AS	[SQL Server Service],
		startup_type_desc						AS	[Start Type],
		status_desc								AS	[current status], 
		last_startup_time						AS	[last startup],
		service_account							AS	[Service Account],
		[filename]								AS	[start command]
FROM	sys.dm_server_services WITH (NOLOCK);
GO

-- Information about CPU and Memory
SELECT	DOSI.cpu_count,
		hyperthread_ratio	AS logical_cores_per_socket,
		CAST(DOSI.physical_memory_kb / POWER(1024.0, 2)	AS NUMERIC(10, 2))	AS	PhysicalMem_GB,
		CAST(DOSI.committed_kb / POWER(1024.0, 2) AS NUMERIC(10, 2))		AS	CommittedMem_GB,
		CAST(DOSI.committed_target_kb / POWER(1024.0, 2) AS NUMERIC(10, 2))	AS	CommittedTargetMem_GB,
		DOSI.max_workers_count
FROM	sys.dm_os_sys_info AS DOSI;
GO

-- Are there any mdmp-files for further investigation?
SELECT [filename], creation_time, size_in_bytes
FROM sys.dm_server_memory_dumps;
GO