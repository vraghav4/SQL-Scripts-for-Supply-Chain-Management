Use testDB; 

With cte_BBD As (

select SKU_Lot_Combo, Short_Date_of_Mfg, Count(Distinct(Container)) as Pallet_Count 
from dbo.RSD_Nov_Data 
Where SKU_Lot_Combo is not NULL
group by SKU_Lot_Combo, Short_Date_of_Mfg


),

cte_Distill as (

Select *, Sum(Pallet_Count) over (PARTITION BY SKU_Lot_Combo) As Total_Pallets_in_SKU_Lot, (Pallet_Count * 100.0 / Sum(Pallet_Count) over (PARTITION BY SKU_Lot_Combo)) as Ratio
from cte_BBD
 ) 

Select sum(Pallet_Count) as All_in_Total, sum(Case when Ratio < 50 then Pallet_Count else 0 end) as Pallets_with_Wrong_BBD , 
sum(Case when Ratio < 50 then Pallet_Count else 0 end) * 100.00 / sum(Pallet_Count) as Percent_of_affected_pallets
from cte_Distill
