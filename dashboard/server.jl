using HTTP
using JSON
using PersonalGreenhouse
using ModelingToolkit
using DyadInterface
using OrdinaryDiffEqDefault
using SciMLBase

const ROOT = @__DIR__
const REPORT_PATH = normpath(joinpath(ROOT,"..","Greenhouse_Design_and_Controls_Report.md"))
const YEAR = 31_536_000.0
const MONTH_DAYS = [31,28,31,30,31,30,31,31,30,31,30,31]
const MONTH_END = cumsum(MONTH_DAYS)
const PEAK_SUN_HOURS = [3.4,4.2,5.1,5.8,6.2,6.8,6.7,6.3,5.9,4.7,3.5,3.1]
const PV_YIELD_PER_KW = PEAK_SUN_HOURS .* MONTH_DAYS .* 0.78

println("Preparing geometry-based greenhouse model...")
@named RAW_GREENHOUSE = PersonalGreenhouse.PortfolioGreenhouseAnnual()
const SYS = simplify_model(RAW_GREENHOUSE)
const BASE_PROB = ODEProblem(SYS, [], (0.0, YEAR))
println("Model ready.")

cop(Tc) = clamp(2.8 + 0.06Tc, 1.8, 4.0)
monthof(t) = (d = floor(Int, t/86400) % 365; findfirst(x -> d < x, MONTH_END))

function simulate_crop_scenario(req)
    area = clamp(Float64(req["area_m2"]), 1.0, 80.0)
    crop_water = max(Float64(req["crop_water_Lyear"]), 0.0)
    led_estimate = max(Float64(req["led_kwh_year"]), 0.0)
    reference_area = 21.87
    scale = area/reference_area

    # Geometry remains the explicit 6 x 6 m structure. Slider changes scale the
    # installed crop-group areas inside that fixed envelope. The accepted plan
    # can also pass explicit greenhouse dimensions/materials.
    width = clamp(Float64(get(req,"width_m",6.0)),3.0,20.0)
    length = clamp(Float64(get(req,"length_m",6.0)),3.0,30.0)
    wall_height = clamp(Float64(get(req,"wall_height_m",2.4)),1.8,6.0)
    roof_rise = clamp(Float64(get(req,"roof_rise_m",1.2)),0.3,4.0)

    prob = remake(BASE_PROB; p=[
        SYS.width => width, SYS.length => length,
        SYS.wall_height => wall_height, SYS.roof_rise => roof_rise,
        SYS.A_tomato => 6.75*scale,
        SYS.A_tomatillo => 8.0*scale,
        SYS.A_pepper => 6.60*scale,
        SYS.A_cilantro => 0.52*scale,
    ])

    sol = solve(prob; saveat=3600.0, abstol=1e-4, reltol=1e-4)
    SciMLBase.successful_retcode(sol) || error("annual greenhouse solve ended with $(sol.retcode)")

    ts = sol.t
    dt = diff(ts)
    qheat = [sol(t, idxs=SYS.greenhouse.heater.Q_flow) for t in ts]
    tamb = [sol(t, idxs=SYS.greenhouse.weather.T_ambient)-273.15 for t in ts]
    cmd = [sol(t, idxs=SYS.greenhouse.cool_ctrl.y) for t in ts]
    led = [sol(t, idxs=SYS.greenhouse.growlights.P_elec) for t in ts]
    water = [sol(t, idxs=SYS.greenhouse.evap.mdot_water) for t in ts]
    tair = [sol(t, idxs=SYS.greenhouse.air.T)-273.15 for t in ts]
    rh = [100sol(t, idxs=SYS.greenhouse.moisture.RH) for t in ts]

    hp = qheat ./ cop.(tamb)
    cooling = [300.0c + (c > 0.01 ? 80.0 : 0.0) for c in cmd]
    # The physical LED block is the primary lighting result. Keep the planner
    # estimate in the response so the user can compare empirical vs physical.
    # Continuous portfolio Dutch-bucket (9.88 W) plus herb NFT pump (6.8 W).
    hydro_power = fill(16.68, length(ts))
    total = hp .+ cooling .+ led .+ hydro_power

    integrate(x) = sum((x[1:end-1] .+ x[2:end])./2 .* dt)
    kwh(x) = integrate(x)/3.6e6
    monthly_hp = zeros(12); monthly_cool = zeros(12); monthly_led = zeros(12); monthly_hydro=zeros(12)
    day_load = zeros(365)
    for i in eachindex(dt)
        tm = (ts[i]+ts[i+1])/2
        mo = monthof(tm)
        f = dt[i]/3.6e6
        monthly_hp[mo] += (hp[i]+hp[i+1])/2*f
        monthly_cool[mo] += (cooling[i]+cooling[i+1])/2*f
        monthly_led[mo] += (led[i]+led[i+1])/2*f
        monthly_hydro[mo] += (hydro_power[i]+hydro_power[i+1])/2*f
        dy = min(365, floor(Int,ts[i]/86400)+1)
        day_load[dy] += (total[i]+total[i+1])/2*f
    end
    monthly_total = monthly_hp.+monthly_cool.+monthly_led.+monthly_hydro
    annual_elec = sum(monthly_total)
    pv_grid = annual_elec/sum(PV_YIELD_PER_KW)
    pv_off = maximum(monthly_total./PV_YIELD_PER_KW)
    worst_day = maximum(day_load)
    battery = 1.5worst_day/0.8

    Dict(
      "status"=>"ok", "area_m2"=>area, "scale"=>scale,
      "geometry"=>Dict("width_m"=>width,"length_m"=>length,
        "wall_height_m"=>wall_height,"roof_rise_m"=>roof_rise,
        "floor_m2"=>width*length),
      "heat_thermal_kwh"=>round(kwh(qheat),digits=1),
      "heatpump_kwh"=>round(kwh(hp),digits=1),
      "growlight_kwh"=>round(kwh(led),digits=1),
      "planner_growlight_kwh"=>round(led_estimate,digits=1),
      "cooling_kwh"=>round(kwh(cooling),digits=1),
      "hydro_kwh"=>round(kwh(hydro_power),digits=1),
      "total_kwh"=>round(annual_elec,digits=1),
      "evap_water_L"=>round(integrate(water),digits=0),
      "crop_water_L"=>round(crop_water,digits=0),
      "total_process_water_L"=>round(integrate(water)+crop_water,digits=0),
      "peak_air_C"=>round(maximum(tair),digits=2),
      "min_air_C"=>round(minimum(tair),digits=2),
      "max_rh_pct"=>round(maximum(rh),digits=1),
      "pv_grid_kw"=>round(pv_grid,digits=1),
      "pv_off_kw"=>round(pv_off,digits=1),
      "battery_kwh"=>round(battery,digits=0),
      "monthly"=>Dict("hp"=>monthly_hp,"cool"=>monthly_cool,"led"=>monthly_led,"hydro"=>monthly_hydro)
    )
end

mime(path) = endswith(path,".html") ? "text/html; charset=utf-8" :
             endswith(path,".js") ? "application/javascript; charset=utf-8" :
             endswith(path,".md") ? "text/markdown; charset=utf-8" : "application/octet-stream"

function handler(req)
    target = HTTP.URIs.URI(req.target).path
    if req.method == "POST" && target == "/api/recompute"
        try
            data = JSON.parse(String(req.body))
            result = simulate_crop_scenario(data)
            return HTTP.Response(200,["Content-Type"=>"application/json"],JSON.json(result))
        catch err
            showerror(stderr,err,catch_backtrace()); println(stderr)
            return HTTP.Response(500,["Content-Type"=>"application/json"],JSON.json(Dict("status"=>"error","message"=>sprint(showerror,err))))
        end
    end
    if target == "/report.md"
        return isfile(REPORT_PATH) ? HTTP.Response(200,["Content-Type"=>"text/markdown; charset=utf-8"],read(REPORT_PATH)) : HTTP.Response(404,"Report not found")
    end
    rel = target == "/" ? "index.html" : lstrip(target,'/')
    path = normpath(joinpath(ROOT,rel))
    if !startswith(path,normpath(ROOT)) || !isfile(path)
        return HTTP.Response(404,"Not found")
    end
    HTTP.Response(200,["Content-Type"=>mime(path)],read(path))
end

host = get(ENV,"GREENHOUSE_HOST","127.0.0.1")
port = parse(Int,get(ENV,"GREENHOUSE_PORT","8080"))
println("Dashboard: http://$host:$port")
println("Use Ctrl+C to stop.")
HTTP.serve(handler,host,port)
