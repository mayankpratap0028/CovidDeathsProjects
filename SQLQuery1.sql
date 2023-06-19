-- Data we are using

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM CovidDeaths order by 1,2

-- Total Cases Vs Total deaths in our country

select location,total_cases,total_deaths,round((abs(total_deaths)/abs(total_cases))*100,3) as death_percentage
from CovidDeaths
where location like 'India'
order by location


-- Total cases vs Population 
select location,total_cases,population,round((abs(total_cases)/population)*100,3) as cases_percentage
from CovidDeaths
where location like 'India'
order by location

-- Looking the countries with highest infection rate compared to Population

select location,population,max(total_cases)as TotalInfection, max(round((abs(total_cases)/population)*100,3)) as cases_percentage
from CovidDeaths
where continent is not null
group by location,population
order by cases_percentage desc

-- Looking the countries with highest death rate compared to Population

select location,population,max(cast(total_deaths as int))as TotalDeaths, max(round((cast(total_deaths as int)/population)*100,3)) as death_percentage
from CovidDeaths
where continent is not null
group by location,population
order by death_percentage desc


-- Total number of cases decreasing order
select 
location,max(cast(total_cases as int)) TotalInfection from CovidDeaths
where continent is not null
group by location
order by TotalInfection desc

-- Total number of deaths decreasing order
select 
location,max(cast(total_deaths as int)) TotalDeaths from CovidDeaths
where continent is not null
group by location
order by TotalDeaths desc

-- Total death counts on continents

select continent,sum(TotalDeaths) as TotalDeaths from
(select 
continent,location,max(cast(total_deaths as int)) TotalDeaths from CovidDeaths
where continent is not null
group by continent,location
) as t1
group by continent
order by TotalDeaths desc


-- Global Numbers on each Day

select date, sum(new_cases) as TotalCases, sum(new_deaths) as TotalDeaths ,(sum(new_deaths)/sum(new_cases))*100 DeathPercentage
from CovidDeaths
where continent is not null and new_cases is not null and new_deaths is not null and new_cases !=0
group by  date
order by 1

-- Cases and deaths across the world
select location, sum(new_cases) as TotalCases, sum(new_deaths) as TotalDeaths, (sum(new_deaths)/sum(new_cases))*100 as DeathPercentage
from CovidDeaths
where location = 'World'
group by location

-- Looking total population vs vaccinations
-- By CTE

with PopvsVac (continent,location,date,population,new_vaccinations,rollingpeoplevaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from CovidDeaths as dea
inner join CovidVaccinations as vac
on dea.date = vac.date
and dea.location = vac.location
where dea.continent is not null and vac.new_vaccinations is not null
-- order by 2,3
)
Select *,(rollingpeoplevaccinated/population)
from PopvsVac

--BY Table


Create Table #vaccinationVSpopluation(
Continent varchar(255),
Location varchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
vaccVSpop numeric,
)
insert into #vaccinationVSpopluation
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from CovidDeaths as dea
inner join CovidVaccinations as vac
on dea.date = vac.date
and dea.location = vac.location
where dea.continent is not null and vac.new_vaccinations is not null
order by 2,3

select * from #vaccinationVSpopluation