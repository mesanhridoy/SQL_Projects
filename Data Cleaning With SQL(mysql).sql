/* 

Cleaning Data With SQL Queries(mysql)

*/

SELECT *
FROM `nashville housing data for data cleaning`


-- Standardizing Date to necessary Format 
-- DATE to DATETIME 
-- DATETIME TO DATE 

Select SaleDate, saledateconverted
From `nashville housing data for data cleaning`

Update `nashville housing data for data cleaning`
SET SaleDate = CONVERT(SaleDate, DATETIME)

Update `nashville housing data for data cleaning`
SET SaleDate = CONVERT(SaleDate, DATE)

-- Adding new coulumn with Date with DATETIME format 

ALTER TABLE `nashville housing data for data cleaning`
ADD saledateconverted DATETIME 

UPDATE `nashville housing data for data cleaning`
SET saledateconverted = CONVERT(SaleDate, DATETIME)

ALter table `nashville housing data for data cleaning`
Drop column saledateconverted 

Select saledateconverted
From `nashville housing data for data cleaning`


-- <Populate Property Address Data>

Select *
From `nashville housing data for data cleaning`
order by parcelid
-- Finding if the there is any repition in parcel id and property address 

SELECT parcelID, COUNT(*) as occurrence_count
FROM `nashville housing data for data cleaning`
GROUP BY parcelid
HAVING COUNT(*) > 1;

SELECT parcelID, propertyaddress
from `nashville housing data for data cleaning`
where parcelid = '015 14 0 060.00'

SELECT old.parcelid,old.propertyaddress,new.parcelid , new.propertyaddress 
FROM `nashville housing data for data cleaning` Old
JOIN `nashville housing data for data cleaning` New
ON Old.parcelid = New.parcelid
AND Old.uniqueid <> new.uniqueid        
WHERE Old.parcelid IS NULL

 
FROM `nashville housing data for data cleaning` Old, IFNULL(old.propertyaddress, new.propertyaddress)
JOIN `nashville housing data for data cleaning` New
ON Old.parcelid = New.parcelid
AND Old.uniqueid <> new.uniqueid        
WHERE Old.parcelid IS NULL


UPDATE `nashville housing data for data cleaning` AS Old
JOIN `nashville housing data for data cleaning` AS New
ON Old.parcelid = New.parcelid
AND Old.uniqueid <> New.uniqueid
SET Old.propertyaddress = IFNULL(Old.propertyaddress, New.propertyaddress)
WHERE Old.propertyaddress IS NULL;



-- <Breaking out address into individual columns (Address, City , State)>



Select substr(PropertyAddress, 1, LOCATE(',',propertyaddress)-1) as address,
substr(PropertyAddress, LOCATE(',',propertyaddress)+1, length(PropertyAddress)) as address1
From `nashville housing data for data cleaning`

/*Select substr(PropertyAddress, 1, LOCATE(',',propertyaddress)-1) as address,
substr(PropertyAddress, LOCATE(',',propertyaddress)+1, length(PropertyAddress)) as address1,
SUBSTRING(PropertyAddress, LOCATE('D', PropertyAddress), LOCATE(', ', PropertyAddress) - LOCATE('D', PropertyAddress))  as address2
from `nashville housing data for data cleaning`
*/

Alter Table `nashville housing data for data cleaning`
Add propertysplitaddress varchar(255);

Update `nashville housing data for data cleaning`
set propertysplitaddress = substr(PropertyAddress, 1, LOCATE(',',propertyaddress)-1)

Alter Table `nashville housing data for data cleaning`
Add propertysplitcity varchar(255);

Update `nashville housing data for data cleaning`
set propertysplitcity = substr(PropertyAddress, LOCATE(',',propertyaddress)+1, length(PropertyAddress))

Select propertysplitaddress, propertysplitcity
from `nashville housing data for data cleaning`
 

Select SUBSTRING_INDEX(owneraddress,',',1),
SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', -2), ',', 1),
SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', -1),',',1)
from `nashville housing data for data cleaning`


Alter Table `nashville housing data for data cleaning`
Add Ownersplitaddress varchar(255);

Update `nashville housing data for data cleaning`
set Ownersplitaddress = SUBSTRING_INDEX(owneraddress,',',1)

Alter Table `nashville housing data for data cleaning`
Add Ownersplitcity varchar(255);

Update `nashville housing data for data cleaning`
set Ownersplitcity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', -2), ',', 1)

Alter Table `nashville housing data for data cleaning`
Add Ownersplitstate varchar(255);

Update `nashville housing data for data cleaning`
set Ownersplitstate = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', -1),',',1)


-- <Change Y and N to Yes and No in SoldAsVacant field>
-- First we find out how many different versions of Yes and No exists in the TABLE
-- Then we use CASE()

SELECT DISTINCT
	( SoldAsVacant ),
	Count( SoldAsVacant ) 
FROM
	`nashville housing data for data cleaning` 
GROUP BY
	SoldAsVacant 
ORDER BY
	2
	
Select SoldAsVacant,
Case When SoldAsVacant = 'Y' Then 'Yes'
		 When SoldAsVacant = 'N' Then 'No'
		 Else SoldAsVacant
		 END
From `nashville housing data for data cleaning`

UPDATE `nashville housing data for data cleaning`
Set SoldAsVacant = 
Case When SoldAsVacant = 'Y' Then 'Yes'
		 When SoldAsVacant = 'N' Then 'No'
		 Else SoldAsVacant
		 END


-- Remove Duplicates with CTE 

WITH RowNumCTE AS(
Select *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference
ORder by UniqueID) row_num 
from `nashville housing data for data cleaning`
order by ParcelID)

SELECT *
FROM RowNumCTE
WHERE row_num = 1


-- <Delete Ununsed Columns>

SELECT *
FROM `nashville housing data for data cleaning`

ALTER TABLE `nashville housing data for data cleaning`
DROP COLUMN PropertyAddress,
DROP COlUMN OwnerAddress, 
DROP COLUMN TaxDistrict;

 





