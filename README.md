# xJ-Billing
A billing system remake version of xJoww with ESX and OX Lib supports. (based from ESX_Billing)

## Download and Installation
### Using Git
Make sure you have **Git** installed on your base system, [learn more](https://git-scm.com/downloads)
```
https://github.com/xJoww/xJ-Billing.git
```
### Manually
- Download the [resource](https://github.com/xJoww/xJ-Billing/archive/refs/heads/main.zip)
- Move the resource to your server folder
## Installation
- Import `billing.sql` into your database
- Make sure to ensure the resource in `server.cfg`:
  ```
  ensure xJ-Billing
  ```
## Usage
- Only Whitelist Jobs are able to issues and check a bill:
  - Police `society_police`
  - Ambulance `society_ambulance`
  - Mechanic `society_mechanic`
  - Restaurant `society_restaurant`
  - Taxi `society_taxi`
- Use `/mybills` or `F7` to check your pending billings by default
- Use third eye to issues a bill
- Use third eye to check someones bill
## Configuration
Simply open `shared/config.cfg` and feel free to customize:
```lua
Config = {}
Config.UseThirdEye      = true
Config.BillKeybind      = "F7"
Config.BillCommand      = "mybills"
Config.BillDescription  = "Check all of your pending billings"
```