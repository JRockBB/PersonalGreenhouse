# Autonomous Greenhouse Design and Controls Report

**Project:** Personal greenhouse for year-round salsa crops  
**Reference site:** Denver, Colorado  
**Design status:** Parametric concept model and controls reference design  
**Primary crops:** Tomatoes, peppers, cilantro, and compact herbs

---

## 1. Executive summary

The proposed system is a greenhouse with:

- A triple-wall transparent envelope, insulated opaque north wall, and night infrared curtain.
- A cold-climate heat pump for winter heating.
- Shade, ventilation, and direct evaporative cooling for summer temperature control.
- Dimmable LED grow lights controlled against measured natural PPFD.
- A 12-bucket recirculating Dutch-bucket loop for tomatoes and peppers.
- Automatic reservoir top-off and nutrient-stock dosing.
- A separate herb NFT loop to be designed later.
- Local PLC control for life-safety and plant-survival functions.
- A supervisory mini PC for logging, dashboards, forecasts, and computer vision.

The current synthesized Denver-year model indicates the following for the **improved envelope**:

| Metric | Modeled result |
|---|---:|
| Heat-pump electricity | 1,746 kWh/year |
| Grow-light electricity | 3,914 kWh/year |
| Evaporative-cooling electricity | 370 kWh/year |
| Hydroponic circulation electricity | 80 kWh/year |
| **Total modeled electricity** | **6,110 kWh/year** |
| Grid-tied net-zero PV estimate | **4.2 kW** |
| Fully off-grid PV estimate | **10.5 kW** |
| Fully off-grid battery estimate | **51 kWh** |
| Evaporative-cooling water | 6,998 L/year |
| Hydroponic top-off water | 7,064 L/year |
| **Modeled site process water** | **about 14,062 L/year** |

The grid-tied solar configuration is substantially smaller and less sensitive to prolonged winter cloud cover than the fully off-grid configuration. The energy result does not yet include every auxiliary load, such as the supervisory computer, cameras, circulation fans, dosing pumps, and miscellaneous standby power. These should be included before final PV procurement.

---

## 2. Scope and assumptions

### 2.1 Climate setpoints

| Variable | Current target |
|---|---:|
| Night heating floor | 15 °C |
| Day heating target | 18 °C |
| Cooling ceiling | 27 °C |
| Evaporative-cooling RH ceiling | 80% |
| Grow-light target | 380 µmol/m²/s PPFD |
| Photoperiod | 16 hours |
| Illuminated canopy | 12 m² |

### 2.2 Relocation parameters

The model exposes the main site-dependent inputs so it can be re-run for another location:

- Latitude/solar assumptions and daylight duration.
- Seasonal and diurnal outdoor-temperature amplitudes.
- Outdoor humidity ratio.
- Atmospheric pressure, which affects psychrometrics and evaporative cooling.
- Peak transmitted solar gain.
- Envelope conductance and night-sky radiation factor.
- Heat-pump COP relationship.
- PV solar resource and derating.
- Crop temperature, humidity, PPFD, and photoperiod targets.
- Reservoir, pipe, pump, emitter, and elevation geometry.

The current annual weather is synthesized rather than a measured TMY file. It is suitable for option comparison and preliminary sizing, but equipment procurement should use a Denver TMY/weather file and manufacturer performance data.

### 2.3 Crop-portfolio planning scenario

The energy and water loads depend on the crop mix, maturity schedule, canopy area, and salsa recipes. The dashboard therefore includes an interactive planning layer with sliders for:

- Salsa roja / cooked tomato salsa.
- Pico de gallo.
- Tomatillo salsa verde.
- Roasted pepper salsa.
- Extra-hot and specialty salsa.
- Recipe-specific Serrano, poblano, habanero, Thai bird’s eye/Hawaiian, jalapeño, chilaca, and mirasol shares for each salsa family.
- Weekly 500 mL-equivalent production and crop-loss reserve.

The pepper mix is nested inside each salsa recipe rather than applied as a separate global distribution. For example, roasted-pepper salsa defaults toward poblano/chilaca/mirasol, pico defaults toward jalapeño/serrano, and the extra-hot family defaults toward habanero/Thai bird’s eye. Changing the salsa-family sliders therefore changes total variety demand directly, while the selected recipe's pepper sliders control how its own pepper ingredient is allocated.

The initial scenario is four 500 mL jars per week, a 20% reserve, and a 30/20/25/15/10 salsa-family mix. Under the conservative planning coefficients currently loaded in the dashboard, that initial portfolio estimates approximately:

| Planning output | Initial slider result |
|---|---:|
| Tomatoes | 70.4 kg/year; 9 plants |
| Tomatillos | 36.7 kg/year; 10 plants |
| Total peppers | 26.8 kg/year; 17 plants across seven varieties |
| Cilantro | 4.2 kg/year; 13 succession/NFT sites |
| Total productive canopy allocation | 21.2 m² |
| Crop irrigation/top-off estimate | 17,005 L/year |
| Outdoor/stored onions and garlic | 19.7 kg/year |

This result exceeds the earlier equivalent 12 m² / 12-bucket assumption. That is useful: it indicates that four jars per week with all seven pepper varieties may require more greenhouse area, lower production frequency, fewer simultaneous varieties, higher verified yields, or seasonal overflow production.

The dashboard can also perform an explicit server-side annual thermal/moisture re-simulation for the current slider scenario. Start `dashboard/start_dashboard.bat`, open `http://127.0.0.1:8080`, and press **Recompute thermal + moisture model**. This scales the modeled envelope, thermal mass, transpiration, lighting, cooling, and annual energy calculation to the current planned canopy and crop-water estimate. It is intentionally button-driven rather than re-running on every slider movement.


The sliders themselves use recipe and crop coefficients; they do **not** re-run the physical model automatically. The explicit re-simulation button runs the coupled annual thermal/moisture model with aggregate crop-scaled parameters. Before final procurement, the accepted portfolio should still be represented with crop-specific growth stages, PPFD, temperature, and water-demand schedules.

---

## 3. Greenhouse climate and energy system

### 3.1 Recommended envelope

- Triple-wall polycarbonate glazing.
- Insulated, opaque north wall where solar collection is not useful.
- Retractable night infrared curtain.
- Controlled infiltration and sealed service penetrations.
- Passive water/structure thermal mass.

The modeled envelope comparison suggests that the combined upgrades reduce the winter design-day heating load from approximately 122 to 49 kWh/day and the peak heating requirement from approximately 8.5 to 4.3 kW.

### 3.2 Heating

Use a cold-climate air-source heat pump with:

- Manufacturer capacity data at Denver winter temperatures.
- Low-ambient operation.
- A dry-contact thermostat interface or approved communications gateway.
- Independent freeze-protection backup heat.
- Condensate and defrost drainage designed for freezing weather.

The PLC should request heat through an approved low-voltage interface. It should not directly switch compressor power.

### 3.3 Summer cooling

The modeled sensible-only strategy—shade plus ventilation—cannot hold 27 °C when outdoor air reaches approximately 34 °C. Direct evaporative cooling is therefore part of the reference design.

The current design-day model indicates:

- Peak greenhouse air temperature near 27 °C.
- Peak RH below the 80% control ceiling.
- Peak summer evaporative water use around 84 L/day after LED heat is included.
- Fan and pump electricity small compared with heating and grow lights.

Evaporative cooling should be locked out when RH, leaf wetness, or condensation risk is excessive.

### 3.4 Supplemental lighting

Current modeled assumptions:

| Parameter | Value |
|---|---:|
| Canopy area | 12 m² |
| Target PPFD | 380 µmol/m²/s |
| Maximum supplemental PPFD | 380 µmol/m²/s |
| LED efficacy | 2.7 µmol/J |
| Photoperiod | 05:00–21:00 |

The lighting controller supplies only the deficit between natural canopy PPFD and the target. Nearly all LED electricity eventually becomes greenhouse heat, reducing winter heating but increasing summer cooling.


### 3.5 Geometry- and crop-specific annual validation

The aggregate area-scaling model has been replaced by an explicit 6 m × 6 m pitched-roof geometry and crop-group loading. Default parameters are:

| Geometry/crop parameter | Value |
|---|---:|
| Floor area | 36.0 m² |
| Wall height / roof rise | 2.4 m / 1.2 m |
| Roof area | 38.77 m² |
| Transparent envelope area | 78.37 m² |
| Insulated north wall | 18.0 m² |
| Internal volume | 108.0 m³ |
| Envelope conductance | 157.93 W/K |
| Effective radiation factor | 16.55 m²-equivalent |
| Peak effective solar gain | 9.01 kW |
| Installed / active crop canopy | 21.87 / 19.70 m² |
| Weighted PPFD target | 389 µmol/m²/s |
| Weighted transpiration fraction | 0.214 |

The synthesized-year solve completed with the following default-portfolio results:

| Annual result | Geometry/crop model |
|---|---:|
| Heating thermal energy | 13,737 kWh |
| Heat-pump electricity | 5,095 kWh |
| Supplemental LED electricity | 6,877 kWh |
| Evaporative-cooling electricity | 242 kWh |
| Both hydroponic pumps | 146 kWh |
| **Total modeled electricity** | **12,360 kWh/year** |
| Evaporative-cooling water | 7,022 L/year |
| Peak heating demand | 9.02 kW thermal |
| Controlled temperature range | 14.76–27.01 °C |
| Preliminary grid-tied PV | 8.4 kW |
| Preliminary off-grid PV / battery | 22.6 kW / 112 kWh |

These values supersede the earlier 12 m² headline estimate. Grow lighting is now the largest electrical load because the accepted portfolio nearly doubles active canopy. The maximum modeled winter RH remains near saturation, reinforcing the need for condensation management or heat-recovery dehumidification in detailed design.


---

## 4. Hydroponic system

### 4.1 Crop architecture

- **Tomatoes and peppers:** recirculating drip-fed Dutch buckets with vertical trellising.
- **Cilantro and compact herbs:** a separate NFT loop, to avoid forcing fruiting crops and herbs to share nutrient strength and root-zone conditions.

### 4.2 Portfolio-sized fruiting loop and preliminary layout

The default four-jars/week portfolio estimates 36 fruiting plants and approximately 21.2 m² of productive canopy. The resized hydraulic concept uses:

- 36 Dutch buckets split into three balanced 12-emitter manifolds.
- A 200 L-class fruiting-crop reservoir.
- A 16 mm-ID, approximately 8 m main supply trunk.
- Three 10 mm-ID, approximately 2 m branch lines with isolation/balancing valves.
- One inertial liquid-column state per branch to represent manifold redistribution.
- A pump sized for roughly **1.2–1.8 L/min total flow** at the required head, with additional fouling margin.

A practical preliminary greenhouse footprint is **6 m × 6 m (36 m²)**. One conceptual allocation is:

| Area use | Approximate allocation |
|---|---:|
| Fruiting crop canopy/trellis footprint | 21–23 m² |
| Two NFT channels and herb service area | 2–3 m² |
| Central and cross aisles | 7–8 m² |
| Reservoirs, controls, dosing and HVAC service | 3–4 m² |
| Remaining clearance/flex area | 1–3 m² |

Place the insulated service/north wall on the north side with reservoirs, controls, heat pump interfaces and nutrient storage along it. Arrange three 12-plant trellised Dutch-bucket manifolds as north–south crop rows so their balancing valves remain accessible from an aisle. Mount the two NFT herb channels near the cooler north/service side, stacked only if both tiers can receive measured PPFD and service access.

This is a layout basis rather than a construction drawing. Final spacing must use selected cultivars, trellis method, local structural/snow code, door/egress requirements, and actual HVAC clearances.

The compiled three-manifold model was tuned to 92% pump speed and validated at:

| Portfolio-sized hydraulic metric | Result |
|---|---:|
| Total flow | 1.302 L/min |
| Per-plant delivery | 2.169 L/h |
| Branch imbalance | < 2×10⁻¹³% |
| Pump head | 4.303 m |
| Pump electrical power | 9.88 W |
| Continuous annual pump electricity | 86.6 kWh |
| Pressure-balance residual | 7.3×10⁻¹² Pa |
| Reservoir net circulation flow | 0 kg/s |

### 4.3 Original 12-bucket hydraulic reference

| Metric | Result |
|---|---:|
| Bucket/emitter count | 12 |
| Total circulation | 0.427 L/min |
| Average delivery | 2.136 L/h per plant |
| Vertical lift | 2.5 m |
| Supply pipe | 5 m, 12 mm ID |
| Pump power | 9.1 W modeled |
| Pump electricity | 79.5 kWh/year |
| Crop water withdrawal | 7,071 L/year |
| Pure-water top-off | 7,064 L/year |
| Nutrient-stock solution | 7.1 L/year, single-stock proxy |
| Nutrient concentration proxy | 2.0 g/kg solution |

The hydraulic pressure and mass balances close numerically. The tank level and concentration remain at their targets under the idealized top-off and dosing controls.

### 4.4 Emitter and pump warning

The hydraulic model assumes **low-pressure emitters delivering about 2 L/h at approximately 10 kPa (0.1 bar)**. Many commercial pressure-compensating emitters require approximately 100 kPa. Substituting a conventional 1-bar emitter would increase required pump head from roughly 4 m to more than 12 m.

### 4.5 Separate cilantro/herb NFT loop

A separate nutrient loop was modeled for cilantro and compact herbs:

| Metric | Modeled result |
|---|---:|
| Channels | 2 parallel channels |
| Channel length / sites | 2 m / 7 sites each |
| Total NFT positions | 14 |
| Succession occupancy | 7–14 active sites |
| Planting cycle | 30 days, 28 days occupied |
| Flow per channel | 0.607 L/min |
| Operating film depth | 5.90 mm |
| Reservoir | approximately 50 L |
| Herb nutrient target | 1.5 g/kg solution proxy |
| Annual herb water withdrawal | 432.6 L |
| Annual pure-water top-off | 432.3 L |
| Annual nutrient-stock solution | 0.346 L |
| Annual NFT pump electricity | 59.6 kWh |

The channel model includes liquid holdup as a state. At shutdown, the 4 mm nominal film reaches the 1 mm dry-alarm threshold after 96 seconds and drains to empty in approximately 192 seconds. Nominal flow and holdup mass match their independent calculations, and the annual water/nutrient balances close within integration tolerance.

The model identified an important numerical formulation issue: directly solving the quadratic inlet restriction at zero pressure produced a nearly flat algebraic equation. Explicitly inverting the restriction to mass flow and blocking reverse flow removed that conditioning problem. The final annual NFT model uses an implicit solver because it combines fast pipe/channel dynamics with month-long succession cycles and annual nutrient balances.


Before ordering:

1. Obtain the emitter pressure-flow curve.
2. Obtain the pump head-flow and power curves.
3. Re-run the hydraulic model with those curves.
4. Select a pump with margin for filter fouling, root intrusion, branch imbalance, and piping changes.

For the portfolio-sized 36-bucket loop, target approximately 1.2–1.8 L/min total flow at the required head, regulated by speed control or bypass. Keep an identical spare pump. The earlier 0.6–0.8 L/min target applied only to the 12-bucket reference.

---

## 5. Monitoring and control architecture

### 5.1 Two-layer control

Use two layers:

1. **Local PLC/controller:** climate control, irrigation, dosing limits, alarms, and hard interlocks. It remains functional if the network or PC fails.
2. **Supervisory mini PC:** time-series database, dashboard, weather forecast, computer vision, reports, and setpoint scheduling.

A Raspberry Pi or mini PC should not be the only device protecting plants from freezing, overheating, dry-pump operation, or flooding.

### 5.2 Communications

Preferred order:

1. Wired RS-485/Modbus for pH, EC, pressure, flow, and power meters.
2. Ethernet/PoE for cameras.
3. Wired 24 V digital/analog I/O for critical switches.
4. Wi-Fi only for noncritical measurements.

Use MQTT between supervisory services and the controller. Place cameras on an isolated VLAN where practical.

---

## 6. Reference hardware bill of materials

Product families are examples, not final vendor selections. Confirm environmental ratings, wetted-material compatibility, electrical listing, and current specifications before purchase.

### 6.1 Controls and electrical panel

| Qty. | Item | Recommended specification | Example class | Budget |
|---:|---|---|---|---:|
| 1 | Main PLC | Ethernet, Modbus TCP/RTU, RTC, expandable I/O | CLICK PLUS or similar | $250–500 |
| 2 | Analog-input modules | Eight channels each, isolated 4–20 mA/0–10 V | PLC-compatible | $300–600 |
| 2 | Digital-input modules | At least 16 total 24 VDC inputs | PLC-compatible | $120–250 |
| 2 | Digital-output modules | At least 16 relay/transistor outputs | PLC-compatible | $150–300 |
| 1 | Analog-output module | Four isolated 0–10 V outputs | PLC-compatible | $150–300 |
| 1 | 24 VDC supply | 8–10 A DIN-rail | Mean Well or similar | $80–160 |
| 1 | DC UPS module | PLC, network, and critical pump backup | DIN-rail UPS | $150–400 |
| 1 | Backup battery | 24 V, approximately 15–20 Ah LiFePO₄ | Listed battery/BMS | $150–300 |
| 1 | Main enclosure | NEMA 4X polycarbonate, about 24×20 in | Hoffman/Bud class | $200–450 |
| 12–16 | Interposing relays | 24 VDC coil, indication, suppression | DIN-rail industrial | $120–300 |
| 4–8 | Contactors | Sized after actuator selection | Listed DIN-rail | $150–400 |
| 1 | Surge protector | Listed Type 2 SPD | Panel mounted | $80–180 |
| 1 | Emergency stop | Maintained, twist release, dual contact | Industrial 22 mm | $30–80 |
| 1 | Alarm beacon/buzzer | 24 VDC audible/visual | Stack-light class | $50–150 |

### 6.2 Climate instrumentation

| Qty. | Measurement | Recommended specification | Budget |
|---:|---|---|---:|
| 4 | Temperature/RH | Modbus or 4–20 mA, filtered and aspirated | $400–1,000 |
| 1 | PAR/PPFD | Full-spectrum quantum sensor | $300–500 |
| 1 | CO₂ | NDIR, 0–5,000 ppm | $120–350 |
| 1 | Leaf wetness | Analog grid sensor | $150–250 |
| 2 | Surface temperature | Class-A PT100 plus transmitters | $120–300 |
| 1 | Atmospheric pressure | Digital or industrial transmitter | $20–150 |
| 1 | Door contact | Normally closed magnetic contact | $10–30 |
| 1 | Rain sensor | Heated or optical | $50–200 |
| 1 | Wind sensor | Cup or ultrasonic | $100–400 |
| 1 | Smoke/heat detector | Listed detector with relay output | $50–150 |

Recommended temperature/RH locations: low zone, canopy, high zone, and outdoors in a shaded radiation shield. Use the aspirated canopy probe for primary climate control.

### 6.3 Reservoir instrumentation

| Qty. | Item | Recommended specification | Budget |
|---:|---|---|---:|
| 1 | Reservoir | 100–120 L, opaque, covered, food-compatible HDPE | $80–200 |
| 1 | pH probe/transmitter | Double junction, isolated 4–20 mA or Modbus | $250–750 |
| 1 | EC probe/transmitter | Temperature compensated, suitable range | $250–750 |
| 1 | Solution temperature | PT100 or stainless digital probe | $40–120 |
| 1 | Continuous level | 0–1 m vented hydrostatic, 4–20 mA | $120–300 |
| 1 | Low-level float | Independent, normally closed | $20–60 |
| 1 | High-level float | Independent backup cutoff | $20–60 |
| 1 | Leak detector | Relay rope or multiple spot sensors | $80–250 |
| 1 | Top-off meter | Approximately 0.02–2 L/min, pulse output | $80–250 |
| 2 | Nutrient-stock scales | 10–20 kg load-cell platforms | $80–200 total |

### 6.4 Recirculation loop

| Qty. | Item | Recommended specification | Budget |
|---:|---|---|---:|
| 1 | Main fruiting-loop pump | 24 VDC BLDC; target 1.2–1.8 L/min at required head | $100–300 |
| 1 | Herb NFT pump | 24 VDC BLDC; approximately 1.2 L/min total at required head | $60–200 |
| 1 | Spare pump | Identical, stored dry and tested periodically | $80–250 |
| 1 | Supply flow meter | Approximately 0.05–2 L/min | $100–300 |
| 1 | Return-flow switch | Independent proof of return | $30–100 |
| 2 | Pressure transmitters | 0–100 kPa gauge, 4–20 mA | $160–400 |
| 1 | Disc filter | 120 mesh with flush valve | $30–100 |
| 12 | Emitters | Low-pressure, adjustable near 2 L/h at 10 kPa | $25–80 |
| 12 | Branch valves | Balancing and isolation | $30–100 |
| 1 | Bypass valve | Manual pump adjustment | $15–50 |
| 1 | Check valve | Low cracking pressure | $15–50 |
| — | Supply tubing | Approximately 12 mm ID main line | $50–150 |
| — | Return piping | Gravity return sized against blockage | $50–150 |

### 6.5 Water and nutrient actuators

| Qty. | Item | Recommended specification | Budget |
|---:|---|---|---:|
| 1 | Top-off valve | 24 VDC, normally closed, potable-water compatible | $40–120 |
| 1 | Mechanical backup float | Independent high-level cutoff | $20–50 |
| 2 | Nutrient pumps | Separate A and B, 10–30 mL/min peristaltic | $150–500 |
| 1 | pH-down pump | Approximately 5–15 mL/min | $75–250 |
| 1 | Spare/pH-up pump | Install but leave disabled initially | $75–250 |
| 4 | Chemical containers | Opaque, vented, secondary containment | $80–200 |
| 4 | Injection check valves | Chemical compatible | $40–120 |
| 1 | Backflow protection | Code-approved device or physical air gap | $50–300 |

A solenoid valve alone is not adequate potable-water backflow protection.

### 6.6 Supervisory computer and computer vision

| Qty. | Item | Recommended specification | Budget |
|---:|---|---|---:|
| 1 | Mini PC | N100-class, 16 GB RAM, 500 GB SSD | $200–400 |
| 1 | PoE switch | Managed, eight ports | $100–250 |
| 3 | RGB cameras | 4 MP PoE, RTSP/ONVIF, local operation | $250–700 |
| 1 | AC UPS | 800–1,000 VA | $120–250 |
| 3 | Camera shields | Drip shields and lens hoods | $30–100 |
| 2 | Imaging lights | High-CRI, controlled during captures | $50–150 |
| 1 | Color reference target | Weather resistant | $30–100 |

Camera positions:

1. High-corner greenhouse overview.
2. Tomato/pepper canopy at approximately leaf height.
3. Herb/root-zone/reservoir service view.

Initial vision tasks should be canopy coverage, fruit count/ripeness, wilt, yellowing, missing plants, and camera-obstruction detection. Vision should initially flag anomalies for review rather than act as the sole disease detector.

---

## 7. PLC I/O map

### 7.1 Analog inputs

| Channel | Signal | Format |
|---:|---|---|
| AI-01 | Low-zone temperature | 4–20 mA |
| AI-02 | Low-zone RH | 4–20 mA |
| AI-03 | Canopy temperature | 4–20 mA |
| AI-04 | Canopy RH | 4–20 mA |
| AI-05 | High-zone temperature | 4–20 mA |
| AI-06 | High-zone RH | 4–20 mA |
| AI-07 | Outdoor temperature | 4–20 mA |
| AI-08 | Outdoor RH | 4–20 mA |
| AI-09 | PAR/PPFD | 0–5 V or 4–20 mA |
| AI-10 | CO₂ | 0–10 V or 4–20 mA |
| AI-11 | Reservoir pH | 4–20 mA |
| AI-12 | Reservoir EC | 4–20 mA |
| AI-13 | Solution temperature | 4–20 mA |
| AI-14 | Reservoir level | 4–20 mA |
| AI-15 | Pump discharge pressure | 4–20 mA |
| AI-16 | Post-filter pressure | 4–20 mA |

### 7.2 Digital inputs

| Channel | Signal | Normal state |
|---:|---|---|
| DI-01 | Emergency-stop healthy | Closed |
| DI-02 | Smoke/fire healthy | Closed |
| DI-03 | Reservoir low-level | Closed |
| DI-04 | Reservoir high-level | Open |
| DI-05 | Return-flow proof | Closed while pumping |
| DI-06 | Supply-flow pulses | Pulse |
| DI-07 | Top-off-meter pulses | Pulse |
| DI-08 | Leak system healthy | Closed |
| DI-09 | Greenhouse door | Closed |
| DI-10 | Pump overload/fault | Closed |
| DI-11 | Heat-pump fault | Closed |
| DI-12 | Evaporative-cooler fault | Closed |
| DI-13 | Vent fully open | Limit switch |
| DI-14 | Vent fully closed | Limit switch |
| DI-15 | Shade fully open | Limit switch |
| DI-16 | Shade fully closed | Limit switch |

Critical faults should use normally closed circuits so a broken wire creates an alarm.

### 7.3 Digital outputs

| Channel | Function |
|---:|---|
| DO-01 | Hydroponic pump enable |
| DO-02 | Top-off valve |
| DO-03 | Nutrient A dosing pump |
| DO-04 | Nutrient B dosing pump |
| DO-05 | pH-down dosing pump |
| DO-06 | Spare/pH-up pump |
| DO-07 | Heat-pump enable |
| DO-08 | Backup heater enable |
| DO-09 | Evaporative fan enable |
| DO-10 | Evaporative water pump |
| DO-11 | Circulation fans |
| DO-12 | Grow-light contactor |
| DO-13 | Vent open |
| DO-14 | Vent close |
| DO-15 | Shade drive enable/direction interface |
| DO-16 | Alarm beacon/buzzer |

### 7.4 Analog outputs

| Channel | Function |
|---:|---|
| AO-01 | Grow-light dimming, 0–10 V |
| AO-02 | Evaporative-fan speed |
| AO-03 | Hydroponic-pump speed |
| AO-04 | Spare or heat-pump demand |

---

## 8. Hardwired safety and software interlocks

### 8.1 Hydroponic pump hardwired chain

Wire the pump-enable relay through:

1. Emergency-stop healthy.
2. Reservoir low-level float healthy.
3. Pump overload healthy.
4. Manual service switch.

PLC logic should additionally latch a shutdown when:

- The pump is commanded on but return flow is absent for 10–15 seconds.
- Main flow falls below approximately 0.34 L/min.
- Pressure rises while flow falls, indicating filter or line blockage.
- A leak is detected.

### 8.2 Top-off protection

The top-off valve should be normally closed and disabled by:

- Leak detection.
- High-level float.
- Maximum continuous-open timer.
- Maximum daily volume.

The model predicts approximately 19 L/day average hydroponic top-off. Initial limits can be:

- Warning at 35–40 L/day.
- Hard lockout at 60 L/day.

Tune these after collecting operating data.

### 8.3 Nutrient dosing sequence

1. Confirm circulation flow.
2. Confirm pH/EC values are fresh and plausible.
3. Add a bounded nutrient-A dose.
4. Mix.
5. Add a bounded nutrient-B dose.
6. Mix for 5–10 minutes.
7. Recheck EC.
8. Correct pH only after EC stabilizes.

Disable dosing on no flow, low reservoir level, leaks, implausible probe changes, overdue calibration, or exceeded dose limits. Initially automate A/B nutrients but keep pH correction approval-assisted.

### 8.4 Climate safety overrides

- Independent freeze thermostat for backup heat.
- High-temperature fan/vent override.
- High-RH and leaf-wetness evaporative-cooling lockout.
- Wind/rain protection for vents and shade.
- Smoke alarm equipment shutdown.
- Manual override switches for service and recovery.

---

## 9. Software and data

Recommended stack:

- PLC for deterministic controls and alarms.
- MQTT for supervisory telemetry and commands.
- InfluxDB or TimescaleDB for time-series storage.
- Existing custom HTML dashboard and/or Grafana.
- Julia/Python services for forecasting, reporting, and vision.
- Local image inference with event snapshots.
- Daily encrypted backup.

Suggested sampling:

| Data | Interval |
|---|---:|
| Climate | 10 seconds |
| Hydraulic flow/pressure | 2–5 seconds |
| pH/EC/level | 30–60 seconds |
| Electrical power | 10 seconds |
| Images | 10–15 minutes |

Retain raw high-rate data for approximately 90 days and one-minute aggregates for multiple years.

---

## 10. Monitoring and controls budget

This budget excludes the greenhouse structure, heat pump, grow lights, PV/battery, major fans, and evaporative-cooler hardware.

| Group | Low | High |
|---|---:|---:|
| PLC, I/O, and control panel | $1,300 | $2,700 |
| Climate sensors | $1,000 | $2,400 |
| Hydroponic sensors | $900 | $2,100 |
| Pumps, valves, and dosing equipment | $700 | $1,700 |
| Mini PC, network, and cameras | $700 | $1,500 |
| Wiring, connectors, and installation material | $500 | $1,200 |
| **Total** | **$5,100** | **$11,600** |

A cost-controlled maker-grade implementation may approach $3,500–5,000 by using ESP32/RS-485 nodes and lower-cost pH/EC electronics. Do not reduce hardwired float switches, leak detection, GFCI protection, contactors, emergency stop, or chemical/backflow isolation.

---

## 11. Procurement phases

### Phase 1 — equipment survival

- PLC, enclosure, power supply, UPS, and alarm beacon.
- Canopy and outdoor temperature/RH.
- Reservoir level and independent low-level float.
- Main flow meter and return-flow switch.
- Leak detection.
- Recirculation pump and identical spare.

### Phase 2 — climate control

- PAR sensor.
- Heat-pump interface.
- Fans, vents, and shade interfaces.
- Evaporative-cooler controls.
- Grow-light dimming and energy metering.

### Phase 3 — nutrient automation

- pH and EC transmitters.
- A/B dosing pumps.
- Top-off meter and valve.
- Stock load cells.
- pH-down pump after manual operating data are available.

### Phase 4 — computer vision

- Mini PC and PoE switch.
- Three fixed cameras.
- Controlled imaging lights.
- Color reference target.

---

## 12. Commissioning and next decisions

Before detailed procurement:

1. Select the greenhouse footprint and envelope assembly.
2. Obtain heat-pump low-temperature performance data.
3. Select actual LEDs and obtain efficacy/dimming data.
4. Select low-pressure emitters and obtain their pressure-flow curve.
5. Select the circulation pump and obtain its head-flow-power curve.
6. Update the model with those manufacturer curves.
7. Create an electrical one-line diagram and branch-circuit schedule.
8. Create a panel schematic and terminal plan.
9. Confirm plumbing backflow and electrical requirements with applicable local codes.
10. Use a licensed electrician for line-voltage HVAC, grow-light, fan, PV, and service work.

The next modeling subsystem is the separate NFT herb loop. The next implementation document should be the electrical one-line and PLC panel wiring/terminal schedule after major equipment models are selected.
