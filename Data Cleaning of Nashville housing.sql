/*
PROJECT TWO
TITLE: DATA CLEANING OF THE NASHVILLE HOUSING DATASET USING SQL 
DATA SOURCE: GITHUB

ABOUT:

TASKS:
	1. Standardize date format
	2. Populate property address data
	3. Break Adress columns into individual columns (state, city)
	4. Remove duplicates
	5. Change the Y and N values of certain fields to YES and NO
	6. Delete unused columns
*/

-- Select Data from DB
SELECT *
FROM [portfolioproject2].[dbo].[nashvillehousing]

---------------------------------------------------------------------------------------------
-- 1. Standardize Date Format of the SaleDate column
/*
Here we will create a new column in the table by altering it and setting the data format for the 
new column to match the format we want, then we simply convert the data from the previous column
and have it populate the new column.
*/

ALTER TABLE portfolioproject2.dbo.nashvillehousing
ADD conv_saledate date;

UPDATE portfolioproject2.dbo.nashvillehousing
SET conv_saledate = CONVERT(DATE, SaleDate)

SELECT SaleDate, conv_saledate
FROM portfolioproject2.dbo.nashvillehousing
------------------------------------------------------------------------------------------------
-- 2. Populate property address data where the column has NULL values

/*
For this task, we will find that there are columns that contain the missing information that we want.
For example, the ParcelID column contains both repeated addresses and repeated parcelID values, so if we
have a record with missing property address value, then we can join(self join) the table to itself and populate
the missing data with data from the associated value when the parcel ID matches the ID with missing values.
*/

SELECT *
FROM portfolioproject2.dbo.nashvillehousing
--WHERE PropertyAddress IS NULL

UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM portfolioproject2.dbo.nashvillehousing a
JOIN portfolioproject2.dbo.nashvillehousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<> b.[UniqueID ]

SELECT a.PropertyAddress, b.PropertyAddress
FROM portfolioproject2.dbo.nashvillehousing a
JOIN portfolioproject2.dbo.nashvillehousing b
	ON a.ParcelID = b.ParcelID
where a.PropertyAddress is null;

-----------------------------------------------------------------------------------------------------

-- 3. Break Adress columns into individual columns (state, city)

SELECT *
FROM portfolioproject2.dbo.nashvillehousing

-- 1. SPLIT PROPERTY ADDRESS
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) city
FROM portfolioproject2.dbo.nashvillehousing

ALTER TABLE portfolioproject2.dbo.nashvillehousing
ADD property_address nvarchar(255);

UPDATE portfolioproject2.dbo.nashvillehousing
SET property_address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE portfolioproject2.dbo.nashvillehousing
ADD property_city nvarchar(255);

UPDATE portfolioproject2.dbo.nashvillehousing
SET property_city = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

-- SPLIT OWNER ADDRESS (Containing Address, City, and State into three columns)
-- SAMPLE: 1808  FOX CHASE DR, GOODLETTSVILLE, TN
SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) address,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) city,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) state
FROM portfolioproject2.dbo.nashvillehousing

ALTER TABLE portfolioproject2.dbo.nashvillehousing
ADD new_owneraddress nvarchar(255);

ALTER TABLE portfolioproject2.dbo.nashvillehousing
ADD new_ownercity nvarchar(255);

ALTER TABLE portfolioproject2.dbo.nashvillehousing
ADD new_ownerstate nvarchar(255);

UPDATE portfolioproject2.dbo.nashvillehousing
SET new_owneraddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

UPDATE portfolioproject2.dbo.nashvillehousing
SET new_ownercity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

UPDATE portfolioproject2.dbo.nashvillehousing
SET new_ownerstate = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

---------------------------------------------------------------------------------------------------------------

-- 4. Change the Y and N values of certain fields to YES and NO

SELECT 
	CASE 
		WHEN SoldAsVacant='Y' THEN 'Yes'
		WHEN SoldAsVacant='N' THEN 'No'
		ELSE SoldAsVacant
	END 
FROM portfolioproject2.dbo.nashvillehousing

UPDATE portfolioproject2.dbo.nashvillehousing
SET SoldAsVacant = CASE 
		WHEN SoldAsVacant='Y' THEN 'Yes'
		WHEN SoldAsVacant='N' THEN 'No'
		ELSE SoldAsVacant
	END 

SELECT 
	SoldAsVacant,
	count(SoldAsVacant)
FROM portfolioproject2.dbo.nashvillehousing
group by SoldAsVacant

------------------------------------------------------------------------------------------------------------------

-- 5. Remove duplicates

WITH RowNumCte AS (

SELECT *,
ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SaleDate,
				SalePrice,
				LegalReference
				ORDER BY
				UniqueID
				) as row_num
From portfolioproject2.dbo.nashvillehousing
)

DELETE
FROM RowNumCte
WHERE row_num > 1

--------------------------------------------------------------------------------------------------------------

-- 6. Delete unused columns

SELECT 
	*
FROM portfolioproject2.dbo.nashvillehousing