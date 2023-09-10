--Cleaning data in SQL queries 

select *
from portfolio.dbo.NashvilleHousing

--Standardize date formaat 
 
 Alter table NashvilleHousing
 add SaleDateConverted date 

  Update NashvilleHousing
  set SaleDateConverted = convert(date,SaleDate) 

  select SaleDateConverted
 from portfolio.dbo.NashvilleHousing

alter table  NashvilleHousing 
drop column SaleDate

select *
from portfolio.dbo.NashvilleHousing

--Populate property adress data 

select *
from portfolio.dbo.NashvilleHousing
order by ParcelID

select a.ParcelID , a.PropertyAddress , b.ParcelID , b.PropertyAddress , isnull(a.PropertyAddress,b.PropertyAddress)
from portfolio.dbo.NashvilleHousing a 
join portfolio.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID 
where a.PropertyAddress is null 
 
 update a
set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
from portfolio.dbo.NashvilleHousing a 
join portfolio.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID 
where a.PropertyAddress is null 

--Breaking out adress into individual columns ( adress , city , state ) 

--Adress

select substring ( PropertyAddress , 1 ,charindex (',' ,  PropertyAddress)-1) as adress 
from portfolio.dbo.NashvilleHousing

alter table NashvilleHousing
add Address nvarchar(255) 

update NashvilleHousing 
set Address = substring ( PropertyAddress , 1 ,charindex (',' ,  PropertyAddress)-1)


--City 

select substring ( PropertyAddress , charindex (',' ,  PropertyAddress) +1 ,len( PropertyAddress )) as city 
from portfolio.dbo.NashvilleHousing

alter table NashvilleHousing
add City  nvarchar(255) 

update NashvilleHousing 
set City  = substring ( PropertyAddress , charindex (',' ,  PropertyAddress) +1 ,len( PropertyAddress ))

select *
from portfolio.dbo.NashvilleHousing

alter table NashvilleHousing
drop column PropertyAddress

--OWNER

select OwnerAddress 
from portfolio.dbo.NashvilleHousing

select 
parsename ( replace ( OwnerAddress , ',','.') , 3)  as  , 
parsename ( replace ( OwnerAddress , ',','.') , 2) as , 
parsename ( replace ( OwnerAddress , ',','.') , 1)  as 
from portfolio.dbo.NashvilleHousing

alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255) , OwnerCity nvarchar(255) , OwnerState nvarchar(255)

update NashvilleHousing
set OwnerSplitAddress = parsename ( replace ( OwnerAddress , ',','.') , 3) ,
OwnerCity = parsename ( replace ( OwnerAddress , ',','.') , 2) ,
OwnerState = parsename ( replace ( OwnerAddress , ',','.') , 1)
 
select *
from portfolio.dbo.NashvilleHousing

alter table NashvilleHousing
drop column OwnerAddress

--Change Y and N to Yes and No in  SoldAsVacant 

select distinct( SoldAsVacant ) , count(SoldAsVacant)
from portfolio.dbo.NashvilleHousing
group by SoldAsVacant


select SoldAsVacant , 
case when SoldAsVacant ='n' then 'no' 
when SoldAsVacant ='y' then 'yes' 
else SoldAsVacant 
end 
from portfolio.dbo.NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant ='n' then 'no' 
when SoldAsVacant ='y' then 'yes' 
else SoldAsVacant 
end 



