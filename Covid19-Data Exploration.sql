select *
from Covid19PortfolioProject..Covid19Deaths
where continent is not null
order by 3,4

select *
from Covid19PortfolioProject..Covid19Vaccination
where continent is not null
order by 3,4

-- Selecting Relevant Data for this Analysis

select location, date, population, total_cases, new_cases, total_deaths, new_deaths
from Covid19PortfolioProject..Covid19Deaths
where continent is not null
order by 1,2

-- What is the chance of someone dying if contract covid19
-- Total Cases Vs Total Death

select location, date, population, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Covid19PortfolioProject..Covid19Deaths
where continent is not null
order by 1,2

select location, date, population, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Covid19PortfolioProject..Covid19Deaths
where location like '%Nigeria%'
and continent  is not null
order by 1,2

-- Let's see the percentage of population infected with covid19
-- Total Cases Vs Population

select location, date, population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
from Covid19PortfolioProject..Covid19Deaths
where continent is not null
--and location like '%Nigeria%'
order by 1,2

-- Countries with the Highest Infection Rate compared to their Population 

select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentInfectionRate
from Covid19PortfolioProject..Covid19Deaths
where continent is not null
Group by location, population
order by PercentInfectionRate desc

-- Countries with Highest Death Count per Population 

select location, population, Max(cast(total_deaths as int)) as TotalDeathCount
from Covid19PortfolioProject..Covid19Deaths
where continent is not null
Group by location, population
order by TotalDeathCount desc

-- Let's do exploration by continents 
-- Show the continent with the highest death count per population 
    
select continent, Max(cast(total_deaths as int)) as TotalDeathCount
from Covid19PortfolioProject..Covid19Deaths
where continent is not null
Group by continent
order by TotalDeathCount desc           

--Global numbers 

select SUM(new_cases) as total_cases, SUM(cast (new_deaths as int)) as total_death, SUM(cast (new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
from Covid19PortfolioProject..Covid19Deaths
where continent is not null
--group by date
order by 1,2

-- Assessing Vaccination data 
select *
from Covid19PortfolioProject..Covid19Vaccination

-- Joining Death Table with the Vaccination Table

select*
from Covid19PortfolioProject..Covid19Deaths dea
join Covid19PortfolioProject..Covid19Vaccination vac
	on dea.location = vac.location
	and dea.date = vac.location

-- Let's Explore what Percentage of Population that have been Vaccinated at least one shot 
-- Population Vs Vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(float,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from Covid19PortfolioProject..Covid19Deaths dea
join Covid19PortfolioProject..Covid19Vaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by location, date

--Using Common Table Expression (CTE) to perform Calculation on Partition by in the Previous Querry

With PopVsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated) 
as (
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(float,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
from Covid19PortfolioProject..Covid19Deaths dea
join Covid19PortfolioProject..Covid19Vaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by location, date
)
select *, (RollingPeopleVaccinated/Population)*100 as PercentagePeopleVaccinated
from PopVsVac

--Using Temp Table to Perform Calculation on Partition by in Previous Querry
Drop Table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated (Continent nvarchar(255),
Location nvarchar(255), Date datetime, Population numeric, 
New_vaccinations numeric, RollingPeopleVaccinated numeric)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(float,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from Covid19PortfolioProject..Covid19Deaths dea
join Covid19PortfolioProject..Covid19Vaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by location, date

select *, (RollingPeopleVaccinated/Population)*100 as PercentagePeopleVaccinated
from #PercentPopulationVaccinated

--Creating Views to store data for later visualizations

Create View PercentaPopulatonVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(float,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from Covid19PortfolioProject..Covid19Deaths dea
join Covid19PortfolioProject..Covid19Vaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

