# Smart CRT TV Project - Code Review Memory

## Project Overview
- Processing (Java-based) creative coding project for Raspberry Pi + CRT TV
- Displays rotating "programs": weather, forecast, ISS tracking, electricity usage, animations
- Uses threaded background fetching for API data (OpenWeatherMap, FMI, YR.no, N2YO, Adafruit IO)
- P2D renderer (720x576), targets 50fps on Pi4

## Key Architecture
- `smart_crt_tv.pde`: Main setup/draw loop, program state machine (program_number)
- `functions.pde`: Utility functions, HTTP helper, program cycling logic
- `classes.pde`: Animator, ImageSequence (threaded image loading)
- `object_0_flash.pde`: Transition effect between programs
- Data classes: Weather, ForecastFmi, ForecastYr, IssTracker, ElectricityUse
- Each "program" is a numbered state in the draw() loop

## Known Patterns
- String comparison with `==` instead of `.equals()` is a recurring bug
- API keys are hardcoded (Adafruit IO key in adafruit_io.pde, OpenWeatherMap in weather class)
- Thread safety: uses `volatile` flags but no synchronized blocks for shared data
- `program_cycle` array is size 12 but only programs 1-12 exist (no program 9 in cycle)
- Global mutable state everywhere (Processing style)

## File Paths
- Main: `/Users/valtterimaki/Dropbox (Personal)/Processing/smart_crt_tv/smart_crt_tv.pde`
- All .pde files in same directory
