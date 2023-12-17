use ProjectPortfolio

--Selecting columns to use
select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1,2

--Total Cases vs Total Deaths
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location like '%Saudi%'
order by 1,2

--Total Cases Vs Population
select location, date, population, (total_cases/population)*100 as InfectedPercentage
from CovidDeaths
--where location like '%Saudi%'
order by 1,2

--Highest infection Rate
select location, population, max(total_cases) as HighestInfected, max((total_cases/population))*100 as InfectedPercentage
from CovidDeaths
group by location, population
order by 3 desc

--Highest Death count by location
select location, max(cast(total_deaths as int)) as total_Deaths
from CovidDeaths
where continent is not null
group by location
order by 2 desc

--Highest death count by Continent
select continent, max(cast(total_deaths as int))as total_deaths
from CovidDeaths
where continent is not null
group by continent 
order by total_deaths desc

--Highest death count by Continent - location
select location, max(cast(total_deaths as int))as total_deaths
from CovidDeaths
where continent is null
group by location 
order by total_deaths desc

--Showing global deaths and cases according to date
select date, sum(new_cases) as total_cases, 
sum(cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
from CovidDeaths
where continent is not null
group by date
order by date

--Showing total global deaths and cases
select sum(new_cases) as total_cases, 
sum(cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
from CovidDeaths
where continent is not null

--simple join 
select * 
from CovidDeaths as cd
join CovidVacinations as cv
on cd.location = cv.location
and cd.date = cv.date

--Total vaccinations per day and location
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
from CovidDeaths as cd
join CovidVacinations as cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null
and cv.new_vaccinations is not null
order by 3

--Rolling Total Vaccinations per location 
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(convert(int,cv.new_vaccinations)) over (partition by cd.location order by cd.date) as rollingTotalVaccinations
from CovidDeaths as cd
join CovidVacinations as cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null
and cv.new_vaccinations is not null
order by 2,3

--Rolling Total Vacinations with the percentage of people vaccinated
--use CTE because you can't use a column that is just created i.e. rollingTotalVaccinations, so use cte or temp table to use that column 
with PopulationvsVac (Continent, location, date, population, new_vaccinations, rollingTotalVaccinations)
as
(
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(convert(int,cv.new_vaccinations)) over (partition by cd.location order by cd.date) as rollingTotalVaccinations
from CovidDeaths as cd
join CovidVacinations as cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null
and cv.new_vaccinations is not null
--order by 2,3
)
select *, (rollingTotalVaccinations/population)*100
from PopulationvsVac

--use of temp table
--create TEMP TABLE
drop table if exists percentPopulationVaccination
create table percentPopulationVaccination(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population  numeric,
new_vaccinations numeric,
rollingPeopleVaccinations numeric
)

--Populate temp table 
insert into percentPopulationVaccination
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(convert(int,cv.new_vaccinations)) over (partition by cd.location order by cd.date) as rollingTotalVaccinations
from CovidDeaths as cd
join CovidVacinations as cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null

--use temp table
select *, (rollingPeopleVaccinations/Population)*100 
from percentPopulationVaccination

--Create view for later visualizations
create view percentPopulationVaccinationView
as
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(convert(int,cv.new_vaccinations)) over (partition by cd.location order by cd.date) as rollingTotalVaccinations
from CovidDeaths as cd
join CovidVacinations as cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null

select * 
from percentPopulationVaccinationView