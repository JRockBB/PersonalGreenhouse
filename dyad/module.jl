using CSV

"""
Read an EnergyPlus EPW or a simple weather CSV and return a NamedTuple of
hourly SI-unit arrays. This helper is used by the dashboard/server workflow;
the Dyad annual model itself remains independent of file-system access.

Supported CSV columns (case-insensitive aliases):
- dry-bulb temperature: dry_bulb_C, temperature_C, air_temperature
- relative humidity: relative_humidity_pct, rh_pct, relative_humidity
- global horizontal irradiance: ghi_Wm2, ghi
- wind: wind_speed_ms, wind_speed
- pressure: pressure_Pa, surface_pressure (Pa or hPa; hPa auto-converted)
"""
function load_weather_file(path::AbstractString)
    ext = lowercase(splitext(path)[2])
    if ext == ".epw"
        lines = readlines(path)
        length(lines) >= 8768 || error("EPW file has fewer than 8760 data rows")
        rows = split.(lines[9:end], ',')
        length(rows) >= 8760 || error("EPW file has fewer than 8760 data rows")
        rows = rows[1:8760]
        parsecol(i) = [parse(Float64, r[i]) for r in rows]
        return (time_s=collect(0.0:3600.0:31532400.0),
            dry_bulb_C=parsecol(7), relative_humidity_pct=parsecol(9),
            pressure_Pa=parsecol(10), ghi_Wm2=parsecol(14),
            wind_speed_ms=parsecol(22), source="EPW: "*basename(path))
    elseif ext == ".csv"
        tbl = CSV.File(path)
        names0 = propertynames(first(tbl))
        bylower = Dict(lowercase(String(n))=>n for n in names0)
        function col(aliases; required=true, default=0.0)
            key = findfirst(a->haskey(bylower,lowercase(a)),aliases)
            if isnothing(key)
                required && error("Missing weather column; expected one of "*join(aliases,", "))
                return fill(default,length(tbl))
            end
            n = bylower[lowercase(aliases[key])]
            Float64[getproperty(r,n) for r in tbl]
        end
        temp=col(["dry_bulb_C","temperature_C","air_temperature"])
        rh=col(["relative_humidity_pct","rh_pct","relative_humidity"])
        ghi=col(["ghi_Wm2","ghi"])
        wind=col(["wind_speed_ms","wind_speed"],required=false,default=0.0)
        pressure=col(["pressure_Pa","surface_pressure"],required=false,default=83000.0)
        maximum(pressure)<2000 && (pressure .*= 100.0)
        n=length(temp); n>=8760 || error("Weather CSV must contain at least 8760 hourly rows")
        return (time_s=collect(0.0:3600.0:31532400.0),
            dry_bulb_C=temp[1:8760],relative_humidity_pct=rh[1:8760],
            pressure_Pa=pressure[1:8760],ghi_Wm2=ghi[1:8760],
            wind_speed_ms=wind[1:8760],source="CSV: "*basename(path))
    end
    error("Weather file must have .epw or .csv extension")
end

function humidity_ratio_from_rh(T_C, RH_pct, P_Pa)
    psat=610.94*exp(17.625*T_C/(T_C+243.04))
    pv=clamp(RH_pct/100,0.0,1.0)*psat
    0.622*pv/(P_Pa-pv)
end


"""
Convert imported outdoor weather to the four datasets consumed by `TMYWeather`.
`floor_area` and `solar_utilization` convert GHI to the effective greenhouse
solar-gain signal. Sky temperature uses a bounded clear-sky depression based on
outdoor RH; this remains an approximation unless long-wave sky data are present.
"""
function weather_datasets(weather; floor_area=36.0, solar_utilization=0.3575)
    time = weather.time_s
    T_K = weather.dry_bulb_C .+ 273.15
    rh = weather.relative_humidity_pct
    pressure = weather.pressure_Pa
    w = humidity_ratio_from_rh.(weather.dry_bulb_C, rh, pressure)
    sky_depression = clamp.(6.0 .+ 16.0 .* (1 .- rh./100), 5.0, 22.0)
    T_sky = T_K .- sky_depression
    Q_solar = max.(weather.ghi_Wm2, 0.0) .* floor_area .* solar_utilization
    (ambient=DyadData.DyadTimeseries(hcat(time,T_K);
        independent_var="time_s",dependent_vars=["T_ambient"]),
     sky=DyadData.DyadTimeseries(hcat(time,T_sky);
        independent_var="time_s",dependent_vars=["T_sky"]),
     humidity=DyadData.DyadTimeseries(hcat(time,w);
        independent_var="time_s",dependent_vars=["w_out"]),
     solar=DyadData.DyadTimeseries(hcat(time,Q_solar);
        independent_var="time_s",dependent_vars=["Q_solar"]),
     source=weather.source,
     summary=Dict("T_min_C"=>minimum(weather.dry_bulb_C),
        "T_max_C"=>maximum(weather.dry_bulb_C),
        "RH_mean_pct"=>sum(rh)/length(rh),
        "GHI_kWh_m2_year"=>sum(weather.ghi_Wm2)/1000,
        "wind_mean_ms"=>sum(weather.wind_speed_ms)/length(weather.wind_speed_ms),
        "pressure_mean_Pa"=>sum(pressure)/length(pressure)))
end
