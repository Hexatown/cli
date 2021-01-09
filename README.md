![](./img/hexatown-logo-64h.png)

PowerShell process logic for Microsoft 365

# Ambition 

Build a solution which do not rely on PowerApps Premium Connectors, or on actions in Power Automate or Logic Apps for interacting with Office Graph and Microsoft PowerShell packages.

Make the solution use as many out of the box component on the Microsoft 365 stack to do the job.

## Todo's
- Alpha version [in progress]
- Provide a high level function layer making it easy for Citizen Developers to learn
- Support OneDrive / SharePoint folder as repositories
- Deployment

Visit [hexatown.com](https://www.hexatown.com)

## How to use

### Setup a new project

Prepares a new hexatown.com project

```PowerShell
hexatown init
```

### Package a project
Create a zip package with the source files

```PowerShell
hexatown pack
```

### Launch supporting system

Check current options

```PowerShell
hexatown help go 
```