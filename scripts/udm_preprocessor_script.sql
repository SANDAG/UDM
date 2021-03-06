WITH
--Build Site Spec Capacity Table for Phase Year
site_spec_cap_table as 
(SELECT 
	zum, 
	sum(cap_emp_civ) as cap_emp_civ, 
	sum(cap_hs_sf) as cap_hs_sf,
	sum(cap_hs_mf) as cap_hs_mf, 
	sum(cap_hs_mh) as cap_hs_mh, 
	sum(gq_civ) as gq_civ, 
	sum(gq_mil) as gq_mil	
FROM 
	[sr13].[dbo].[capacity]
WHERE 
	dev_code > 2  --Any developable or redevelopable LCKey
	AND site > 0
	AND phase < 2015
GROUP BY zum),

--Build site spec employment capacity acreage by ZUM
site_spec_acres_emp_table
as
(
SELECT 
	zum,
	0 as site_acres_emp_lu1,
	ISNULL([1],0) as site_acres_emp_lu2,
	ISNULL([2],0) as site_acres_emp_lu3,
	ISNULL([3],0) as site_acres_emp_lu4,
	ISNULL([4],0) as site_acres_emp_lu5,
	ISNULL([5],0) as site_acres_emp_lu6,
	ISNULL([6],0) as site_acres_emp_lu7,
	ISNULL([1],0)+ISNULL([2],0)+ISNULL([3],0)+ISNULL([4],0)+ISNULL([5],0)+ISNULL([6],0) as site_acres_emp_tot
FROM
	(SELECT 
		zum, 
		udm_emp_lu,
		sum(acres) as acres
	 FROM 
		[sr13].[dbo].[capacity]
	 WHERE 
		dev_code > 2 --Any developable or redevelopable LCKey
		AND site > 0
		AND site <> 99 -- Any non road LCKey
		AND udm_emp_lu > 0
	 GROUP BY zum, udm_emp_lu) AS SourceTable
PIVOT
	(
	 AVG(acres) 
	 FOR udm_emp_lu in ([1],[2],[3],[4],[5],[6])
	) as PivotTable),

--Build site spec single family capacity acreage by ZUM
site_spec_acres_sf_table as
(SELECT 
	zum,
	ISNULL([1],0) as site_acres_sf_lu1,
	ISNULL([2],0) as site_acres_sf_lu2,
	ISNULL([3],0) as site_acres_sf_lu3,
	ISNULL([4],0) as site_acres_sf_lu4,
	ISNULL([1],0)+ISNULL([2],0)+ISNULL([3],0)+ISNULL([4],0) as site_acres_sf_tot
FROM
	(SELECT 
		zum, 
		udm_sf_lu, 
		sum(acres) as acres
	 FROM 
		[sr13].[dbo].[capacity]
	 WHERE 
		dev_code > 2  --Any developable or redevelopable LCKey
		AND site > 0
		AND site <> 99
		AND udm_sf_lu > 0
	 GROUP BY zum, udm_sf_lu) AS SourceTable
PIVOT
	(
	 AVG(acres) 
	 FOR udm_sf_lu in ([1],[2],[3],[4])
	) as PivotTable), 

--Build site spec multi-family capacity acreage by ZUM
site_spec_acres_mf_table as
(SELECT 
	zum,
	ISNULL([1],0) as site_acres_mf_lu1,
	ISNULL([2],0) as site_acres_mf_lu2,
	ISNULL([3],0) as site_acres_mf_lu3,
	ISNULL([1],0)+ISNULL([2],0)+ISNULL([3],0) as site_acres_mf_tot
FROM
	(SELECT 
		zum, 
		udm_mf_lu,
		sum(acres) as acres
	 FROM 
		[sr13].[dbo].[capacity]
	 WHERE 
		dev_code > 2 --Any developable or redevelopable LCKey
		AND site > 0
		AND site <> 99
		AND udm_mf_lu > 0
	 GROUP BY zum, udm_mf_lu) AS SourceTable
PIVOT
	(
	 AVG(acres) 
	 FOR udm_mf_lu in ([1],[2],[3])
	) as PivotTable),

--Build total employment capacity by ZUM
cap_emp_table as
(SELECT 
	zum,
	0 as cap_emp_lu1,
	ISNULL([1],0) as cap_emp_lu2,
	ISNULL([2],0) as cap_emp_lu3,
	ISNULL([3],0) as cap_emp_lu4,
	ISNULL([4],0) as cap_emp_lu5,
	ISNULL([5],0) as cap_emp_lu6,
	ISNULL([6],0) as cap_emp_lu7,
	ISNULL([1],0)+ISNULL([2],0)+ISNULL([3],0)+ISNULL([4],0)+ISNULL([5],0)+ISNULL([6],0) as cap_emp_tot
FROM
	(SELECT 
		zum, 
		udm_emp_lu,
		sum(cap_emp_civ) as cap_emp_civ
	 FROM 
		[sr13].[dbo].[capacity]
	 WHERE 
		dev_code > 2 --Any developable or redevelopable LCKey
		AND site = 0
		AND phase < 2015
		AND udm_emp_lu > 0
	GROUP BY zum, udm_emp_lu) as SourceTable
PIVOT
	(
	 avg(cap_emp_civ)
	 FOR udm_emp_lu in ([1],[2],[3],[4],[5],[6])
	) as PivotTable),

--Build total single family capacity by ZUM
cap_sf_table as	
(SELECT 
	zum,
	ISNULL([1],0) as cap_sf_lu1,
	ISNULL([2],0) as cap_sf_lu2,
	ISNULL([3],0) as cap_sf_lu3,
	ISNULL([4],0) as cap_sf_lu4,
	ISNULL([1],0)+ISNULL([2],0)+ISNULL([3],0)+ISNULL([4],0) as cap_sf_tot
FROM
	(SELECT 
		zum, 
		udm_sf_lu,
		sum(cap_hs_sf) as cap_hs_sf
	 FROM 
		[sr13].[dbo].[capacity]
	 WHERE 
		dev_code > 2 --Any developable or redevelopable LCKey
		AND site = 0
		AND phase < 2015
		AND udm_sf_lu > 0
	GROUP BY zum, udm_sf_lu) as SourceTable
PIVOT
	(
	 avg(cap_hs_sf)
	 FOR udm_sf_lu in ([1],[2],[3],[4])
	) as PivotTable),

--Build total multi-family capacity by ZUM
cap_mf_table as
(SELECT 
	zum,
	ISNULL([1],0) as cap_mf_lu1,
	ISNULL([2],0) as cap_mf_lu2,
	ISNULL([3],0) as cap_mf_lu3,
	ISNULL([1],0)+ISNULL([2],0)+ISNULL([3],0) as cap_mf_tot
FROM
	(SELECT 
		zum, 
		udm_mf_lu,
		sum(cap_hs_mf) as cap_hs_mf
	 FROM 
		[sr13].[dbo].[capacity]
	 WHERE 
		dev_code > 2 --Any developable or redevelopable LCKey
		AND site = 0
		AND phase < 2015
		AND udm_mf_lu > 0
	GROUP BY zum, udm_mf_lu) as SourceTable
PIVOT
	(
	 avg(cap_hs_mf)
	 FOR udm_mf_lu in ([1],[2],[3])
	) as PivotTable),

--Build total employmnet capacity acreage by ZUM
acres_emp_table as	
(SELECT 
	zum,
	0 as acres_emp_lu1,
	ISNULL([1],0) as acres_emp_lu2,
	ISNULL([2],0) as acres_emp_lu3,
	ISNULL([3],0) as acres_emp_lu4,
	ISNULL([4],0) as acres_emp_lu5,
	ISNULL([5],0) as acres_emp_lu6,
	ISNULL([6],0) as acres_emp_lu7,
	ISNULL([1],0)+ISNULL([2],0)+ISNULL([3],0)+ISNULL([4],0)+ISNULL([5],0)+ISNULL([6],0) as acres_emp_tot
FROM
	(SELECT 
		zum, 
		udm_emp_lu,
		sum(acres) as acres
	 FROM 
		[sr13].[dbo].[capacity]
	 WHERE 
		dev_code > 2 --Any developable or redevelopable LCKey
		AND site = 0
		AND udm_emp_lu > 0
	GROUP BY zum, udm_emp_lu) as SourceTable
PIVOT
	(
	 sum(acres)
	 FOR udm_emp_lu in ([1],[2],[3],[4],[5],[6])
	) as PivotTable),

--Build total single family capacity acreage by ZUM
acres_sf_table as	
(SELECT 
	zum,
	ISNULL([1],0) as acres_sf_lu1,
	ISNULL([2],0) as acres_sf_lu2,
	ISNULL([3],0) as acres_sf_lu3,
	ISNULL([4],0) as acres_sf_lu4,
	ISNULL([1],0)+ISNULL([2],0)+ISNULL([3],0)+ISNULL([4],0) as acres_sf_tot
FROM
	(SELECT 
		zum, 
		udm_sf_lu,
		sum(acres) as acres
	 FROM 
		[sr13].[dbo].[capacity]
	 WHERE 
		dev_code > 2  --Any developable or redevelopable LCKey
		AND site = 0
		AND udm_sf_lu > 0
	GROUP BY zum, udm_sf_lu) as SourceTable
PIVOT
	(
	 avg(acres)
	 FOR udm_sf_lu in ([1],[2],[3],[4])
	) as PivotTable),

--Build total Multifamily capacity acreage by ZUM
acres_mf_table as
(SELECT 
	zum,
	ISNULL([1],0) as acres_mf_lu1,
	ISNULL([2],0) as acres_mf_lu2,
	ISNULL([3],0) as acres_mf_lu3,
	ISNULL([1],0)+ISNULL([2],0)+ISNULL([3],0) as acres_mf_tot
FROM
	(SELECT 
		zum, 
		udm_mf_lu,
		sum(acres) as acres
	 FROM 
		[sr13].[dbo].[capacity]
	 WHERE 
		dev_code > 2 --Any developable or redevelopable LCKey
		AND site = 0
		AND udm_mf_lu > 0
	GROUP BY zum, udm_mf_lu) as SourceTable
PIVOT
	(
	 avg(acres)
	 FOR udm_mf_lu in ([1],[2],[3])
	) as PivotTable)

SELECT 
	zum_tab.zum as id, 
	ISNULL(ss_cap_tab.cap_emp_civ,0) as cap_emp_civ, 
	ISNULL(ss_cap_tab.cap_hs_sf,0) as cap_hs_sf,
	ISNULL(ss_cap_tab.cap_hs_mf,0) as cap_hs_mf, 
	ISNULL(ss_cap_tab.cap_hs_mh,0) as cap_hs_mh, 
	ISNULL(ss_cap_tab.gq_civ,0) as gq_civ, 
	ISNULL(ss_cap_tab.gq_mil,0) as gq_mil,
	ISNULL(ss_ac_emp_tab.site_acres_emp_lu1,0) as site_acres_emp_lu1,
	ISNULL(ss_ac_emp_tab.site_acres_emp_lu2,0) as site_acres_emp_lu2,
	ISNULL(ss_ac_emp_tab.site_acres_emp_lu3,0) as site_acres_emp_lu3,
	ISNULL(ss_ac_emp_tab.site_acres_emp_lu4,0) as site_acres_emp_lu4,
	ISNULL(ss_ac_emp_tab.site_acres_emp_lu5,0) as site_acres_emp_lu5,
	ISNULL(ss_ac_emp_tab.site_acres_emp_lu6,0) as site_acres_emp_lu6,
	ISNULL(ss_ac_emp_tab.site_acres_emp_lu7,0) as site_acres_emp_lu7,
	ISNULL(ss_ac_emp_tab.site_acres_emp_tot,0) as site_acres_emp_tot,
	ISNULL(ss_ac_sf_tab.site_acres_sf_lu1,0) as site_acres_sf_lu1,
	ISNULL(ss_ac_sf_tab.site_acres_sf_lu2,0) as site_acres_sf_lu2,
	ISNULL(ss_ac_sf_tab.site_acres_sf_lu3,0) as site_acres_sf_lu3,
	ISNULL(ss_ac_sf_tab.site_acres_sf_lu4,0) as site_acres_sf_lu4,
	ISNULL(ss_ac_sf_tab.site_acres_sf_tot,0) as site_acres_sf_tot,
	ISNULL(ss_ac_mf_tab.site_acres_mf_lu1,0) as site_acres_mf_lu1,
	ISNULL(ss_ac_mf_tab.site_acres_mf_lu2,0) as site_acres_mf_lu2,
	ISNULL(ss_ac_mf_tab.site_acres_mf_lu3,0) as site_acres_mf_lu3,
	ISNULL(ss_ac_mf_tab.site_acres_mf_tot,0) as site_acres_mf_tot,
	ISNULL(cap_emp_tab.cap_emp_lu1,0) as cap_emp_lu1,
	ISNULL(cap_emp_tab.cap_emp_lu2,0) as cap_emp_lu2,
	ISNULL(cap_emp_tab.cap_emp_lu3,0) as cap_emp_lu3,
	ISNULL(cap_emp_tab.cap_emp_lu4,0) as cap_emp_lu4,
	ISNULL(cap_emp_tab.cap_emp_lu5,0) as cap_emp_lu5,
	ISNULL(cap_emp_tab.cap_emp_lu6,0) as cap_emp_lu6,
	ISNULL(cap_emp_tab.cap_emp_lu7,0) as cap_emp_lu7,
	ISNULL(cap_emp_tab.cap_emp_tot,0) as cap_emp_tot,
	ISNULL(cap_sf_tab.cap_sf_lu1,0) as cap_sf_lu1,
	ISNULL(cap_sf_tab.cap_sf_lu2,0) as cap_sf_lu2,
	ISNULL(cap_sf_tab.cap_sf_lu3,0) as cap_sf_lu3,
	ISNULL(cap_sf_tab.cap_sf_lu4,0) as cap_sf_lu4,
	ISNULL(cap_sf_tab.cap_sf_tot,0) as cap_sf_tot,
	ISNULL(cap_mf_tab.cap_mf_lu1,0) as cap_mf_lu1,
	ISNULL(cap_mf_tab.cap_mf_lu2,0) as cap_mf_lu2,
	ISNULL(cap_mf_tab.cap_mf_lu3,0) as cap_mf_lu3,
	ISNULL(cap_mf_tab.cap_mf_tot,0) as cap_mf_tot,
	ISNULL(ac_emp_tab.acres_emp_lu1,0) + ISNULL(ss_ac_emp_tab.site_acres_emp_lu1,0) as acres_emp_lu1,
	ISNULL(ac_emp_tab.acres_emp_lu2,0) + ISNULL(ss_ac_emp_tab.site_acres_emp_lu2,0) as acres_emp_lu2,
	ISNULL(ac_emp_tab.acres_emp_lu3,0) + ISNULL(ss_ac_emp_tab.site_acres_emp_lu3,0) as acres_emp_lu3,
	ISNULL(ac_emp_tab.acres_emp_lu4,0) + ISNULL(ss_ac_emp_tab.site_acres_emp_lu4,0) as acres_emp_lu4,
	ISNULL(ac_emp_tab.acres_emp_lu5,0) + ISNULL(ss_ac_emp_tab.site_acres_emp_lu5,0) as acres_emp_lu5,
	ISNULL(ac_emp_tab.acres_emp_lu6,0) + ISNULL(ss_ac_emp_tab.site_acres_emp_lu6,0) as acres_emp_lu6,
	ISNULL(ac_emp_tab.acres_emp_lu7,0) + ISNULL(ss_ac_emp_tab.site_acres_emp_lu7,0) as acres_emp_lu7,
	ISNULL(ac_emp_tab.acres_emp_tot,0) + ISNULL(ss_ac_emp_tab.site_acres_emp_tot,0) as acres_emp_tot,
	ISNULL(ac_sf_tab.acres_sf_lu1,0) + ISNULL(ss_ac_sf_tab.site_acres_sf_lu1,0) as acres_sf_lu1,
	ISNULL(ac_sf_tab.acres_sf_lu2,0) + ISNULL(ss_ac_sf_tab.site_acres_sf_lu2,0) as acres_sf_lu2,
	ISNULL(ac_sf_tab.acres_sf_lu3,0) + ISNULL(ss_ac_sf_tab.site_acres_sf_lu3,0) as acres_sf_lu3,
	ISNULL(ac_sf_tab.acres_sf_lu4,0) + ISNULL(ss_ac_sf_tab.site_acres_sf_lu4,0) as acres_sf_lu4,
	ISNULL(ac_sf_tab.acres_sf_tot,0) + ISNULL(ss_ac_sf_tab.site_acres_sf_tot,0) as acres_sf_tot,
	ISNULL(ac_mf_tab.acres_mf_lu1,0) + ISNULL(ss_ac_mf_tab.site_acres_mf_lu1,0) as acres_mf_lu1,
	ISNULL(ac_mf_tab.acres_mf_lu2,0) + ISNULL(ss_ac_mf_tab.site_acres_mf_lu2,0) as acres_mf_lu2,
	ISNULL(ac_mf_tab.acres_mf_lu3,0) + ISNULL(ss_ac_mf_tab.site_acres_mf_lu3,0) as acres_mf_lu3,
	ISNULL(ac_mf_tab.acres_mf_tot,0) + ISNULL(ss_ac_mf_tab.site_acres_mf_tot,0) as acres_mf_tot
FROM sr13.dbo.zumbase zum_tab
	LEFT JOIN site_spec_cap_table as ss_cap_tab on zum_tab.zum = ss_cap_tab.zum
	LEFT JOIN site_spec_acres_emp_table ss_ac_emp_tab on zum_tab.zum = ss_ac_emp_tab.zum 
	LEFT JOIN site_spec_acres_sf_table ss_ac_sf_tab on zum_tab.zum = ss_ac_sf_tab.zum 
	LEFT JOIN site_spec_acres_mf_table ss_ac_mf_tab on zum_tab.zum = ss_ac_mf_tab.zum 
	LEFT JOIN cap_emp_table cap_emp_tab on zum_tab.zum = cap_emp_tab.zum
	LEFT JOIN cap_sf_table cap_sf_tab on zum_tab.zum = cap_sf_tab.zum
	LEFT JOIN cap_mf_table cap_mf_tab on zum_tab.zum = cap_mf_tab.zum
	LEFT JOIN acres_emp_table ac_emp_tab on zum_tab.zum = ac_emp_tab.zum
	LEFT JOIN acres_sf_table ac_sf_tab on zum_tab.zum = ac_sf_tab.zum
	LEFT JOIN acres_mf_table ac_mf_tab on zum_tab.zum = ac_mf_tab.zum
ORDER BY zum_tab.zum