-- This script is quickly analyze the number of pallets with different best by dates within SKU lots. 

Use testDB; 

-- CTE to create a building block table which combines SKU lots and date of manufacturing and idenfities the number of groups within each SKU lot with different dates of manufacturing 

With cte_BBD As (

select SKU_Lot_Combo, Short_Date_of_Mfg, Count(Distinct(Container)) as Pallet_Count 
from dbo.RSD_Nov_Data 
Where SKU_Lot_Combo is not NULL
group by SKU_Lot_Combo, Short_Date_of_Mfg


),

-- CTE to further distill the cte created above to extract metrics 
 
cte_Distill as (

Select *, Sum(Pallet_Count) over (PARTITION BY SKU_Lot_Combo) As Total_Pallets_in_SKU_Lot, (Pallet_Count * 100.0 / Sum(Pallet_Count) over (PARTITION BY SKU_Lot_Combo)) as Ratio
from cte_BBD
 ) 

-- Final query that provides the # of pallets that are affected with the wrong best by dates within the total production run. For the sake of this project, after conversations with the pertinent groups, it was understood that pallets with wrong best by dates are the minority within a SKU lot combination. i.e. If there is a SKU lot combination with 10 SKUs, 8 pallets have a best by date and 2 pallets have another best by date, the 2 pallets will mostly turn out to have the wrong dates. 

 
Select sum(Pallet_Count) as All_in_Total, sum(Case when Ratio < 50 then Pallet_Count else 0 end) as Pallets_with_Wrong_BBD , 
sum(Case when Ratio < 50 then Pallet_Count else 0 end) * 100.00 / sum(Pallet_Count) as Percent_of_affected_pallets
from cte_Distill
