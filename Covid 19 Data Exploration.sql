-- Covid 19 Data Exploration 

--SKILLS USED : Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types



select *
from portfolio..coviddeaths
order  by 3 , 4

select *
from portfolio..covidvaccinations
order  by  1 , 2

-- Select data that we are going to be starting with

  select location , date , total_cases , new_cases , total_deaths , population
  from portfolio..coviddeaths 
  where cintinent is not null 
  order by 1,2

  -- looking at total cases vs total deaths
  -- the likelyhood to die if you contract the virus in your country 

  select location , date , total_cases ,  total_deaths , (total_deaths / total_cases)*100 as death_percentage
  from portfolio..coviddeaths 
  where location like '%morocco%'
  -- OR : where location = 'morocco'
  order by 1,2

  -- Total cases vs the population 
  -- Shows what percentage of population got covid 

  select location , date ,population ,  total_cases , (total_cases/population)*100 as infection_percentage
  from portfolio..coviddeaths 
  --where location like '%morocco%'
  order by 1 , 2

  -- Countries with highest infection rate 

  select location , population ,  max(total_cases) as highest_infection_rate , max(total_cases/population) * 100 as precentage_infected_population 
  from portfolio..coviddeaths 
  where continent is not null
  group by location , population 
  order by 4 desc

  -- Countries with the highest death count per population 

  select location , population , max ( cast (total_deaths as int) ) as highest_death_rate 
  from portfolio..coviddeaths 
  where continent  is not null  
  group by location , population 
  order by 3 desc
  
  --BREAKING THINGS DOWN BY CONTINENT

  -- Showing continent with the highest death rate per population 

  select continent   , max( cast (total_deaths as int )) as highest_death_rate 
  from portfolio..coviddeaths 
  where continent is  null 
  group by  continent 
  order by 2 desc

  --Drilling down : the numbers of each continent 

  select location , max(total_cases) as cases  , max(total_deaths) as deaths 
  from portfolio..coviddeaths 
  where continent = 'africa'
  group by location 
  order by 2 desc

  -- GLOBAL NUMBERS 

  select  date , sum ( new_cases  ) as total_cases , sum (cast ( new_deaths as int )) as total_deaths ,
   sum (cast ( new_deaths as int )) /sum ( new_cases  ) * 100 as death_percentage
  from coviddeaths 
  where continent is not null
  group by  date 
  order by 2 desc , 3 desc

  --Looking at total polpulation vs total vaccinations 
  select dea.continent ,  dea.location, dea.date , dea.population , vac.new_vaccinations ,
  sum (convert ( int , vac.new_vaccinations)) over (partition by dea.location order by dea.location , dea.date ) as total 
  --the line before is the one responsoble fr adding each days news vacs of each country 
  from portfolio..coviddeaths dea
  join portfolio..covidvaccinations vac
  on dea.location = vac.location
   and dea.date= vac.date
   where dea.continent is not null 
   order by 2 , 3

   -- Number of vaccinated people in each country 
   -- Using CTE
   
   with popvsvac (continent , location , date , population ,new_vaccinations, total )  
   as(
   select dea.continent ,  dea.location, dea.date , dea.population , vac.new_vaccinations ,
  sum (convert ( int , vac.new_vaccinations)) over ( partition by dea.location order by dea.location , dea.date ) as total 
  --, max(total) / dea.population * 100 as precen_vacs 
  from portfolio..coviddeaths dea
  join portfolio..covidvaccinations vac
  on dea.location = vac.location
   and dea.date= vac.date
   where dea.continent is not null 
   )
select * , (total / population) * 100 
 from popvsvac

 --Using temp table 
  drop table if exists #popvsvac
  create table #popvsvac( 
  continent nvarchar (255) , 
  location nvarchar (255) , 
  date datetime   , 
  population numeric  , 
  new_vaccination numeric , 
  total numeric ) 
  
  insert into #popvsvacc
  select dea.continent ,  dea.location, dea.date , dea.population , vac.new_vaccinations ,
  sum (convert ( int , vac.new_vaccinations)) over ( partition by dea.location order by dea.location , dea.date ) as total 
  --, max(total) / dea.population * 100 as precen_vacs 
  from portfolio..coviddeaths dea
  join portfolio..covidvaccinations vac
  on dea.location = vac.location
   and dea.date= vac.date
   
select * , (total / population) * 100 
 from #popvsvac
 --Creating a view for later visualisation 

 create view percentpopulationvaccinated as 
   select dea.continent ,  dea.location, dea.date , dea.population , vac.new_vaccinations ,
  sum (convert ( int , vac.new_vaccinations)) over ( partition by dea.location order by dea.location , dea.date ) as total 
  --, max(total) / dea.population * 100 as precen_vacs 
  from coviddeaths dea
  join covidvaccinations vac
  on dea.location = vac.location
   and dea.date= vac.date
   where dea.continent is not null 

   select * 
   from percentpopulationvaccinated
