-- Cleaning up the data --

Select *
From Covid.dbo.Housing



-- Removing unwanted things from Date Format

Select SaleDateconverted, CONVERT(Date,SaleDate) as Date
From Covid.dbo.Housing


Update Housing
SET SaleDateconverted = CONVERT(Date,SaleDate)


ALTER TABLE Housing
Add SaleDateconverted Date;

Update Housing
SET SaleDateconverted = CONVERT(Date,SaleDate)


 

-- Property adress had Null value and filling it up by orderID

Select *
From Covid.dbo.Housing
Where PropertyAddress is null
order by ParcelID


-- Joining the table if parcelID is same to fill up the Null values

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, 
ISNULL(a.PropertyAddress,b.PropertyAddress) as updated_Add          --If the value isNull if the value is null and we want to populate it.
From Covid.dbo.Housing a
JOIN Covid.dbo.Housing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]                              -- Used to distinguish
Where a.PropertyAddress is null


Update a
SET PropertyAddress = 
ISNULL(a.PropertyAddress,b.PropertyAddress)
From Covid.dbo.Housing a
JOIN Covid.dbo.Housing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null




--------------------------------------------------------------------------------------------------------------------------

--Seperating by Address by Address, City, Stateinto Individual Columns
--seperating by Delimiter (,)

Select PropertyAddress
From Covid.dbo.Housing
--Where PropertyAddress is null
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address                                -- -1 to remove the ","
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From Covid.dbo.Housing


ALTER TABLE Housing
Add PropertySplitAddress Nvarchar(255);

Update Housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE Housing
Add PropertySplitCity Nvarchar(255);

Update Housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, 
                        CHARINDEX(',', PropertyAddress) + 1 , 
						LEN(PropertyAddress))




Select *
From Covid.dbo.Housing



--Breaking the data again by owner adress 

Select OwnerAddress
From Covid.dbo.Housing


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3) as Address                 -- Using parsename instead of substring this time
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2) as City                -- replacing to . first because parsename needs .
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)  as State
From Covid.dbo.Housing



ALTER TABLE Housing
Add OwnerSplitAddress Nvarchar(255);

Update Housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE Housing
Add OwnerSplitCity Nvarchar(255);

Update Housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE Housing
Add OwnerSplitState Nvarchar(255);

Update Housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From Covid.dbo.Housing                    --Resulting in much more sorted data







-- Changing  Y and N in Sold as vacant column


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From Covid.dbo.Housing
Group by SoldAsVacant
order by 2




Select SoldAsVacant                                                        -- Assigning Values to if Y to Yes and N to Yes
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From Covid.dbo.Housing


Update NaHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END



-- Removing Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (                                              
	PARTITION BY ParcelID,                         --
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From Covid.dbo.[Housing]
--order by ParcelID
)
select*

From RowNumCTE
Where row_num > 1                                              --Removing duplicates

Order by PropertyAddress



Select *
From Covid.dbo.Housing



-- Delete Unused Columns

Select *
From Covid.dbo.Housing


ALTER TABLE Covid.dbo.Housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate                           --Droping the columns