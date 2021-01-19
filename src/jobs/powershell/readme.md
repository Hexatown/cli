# Room Manager
The purpose of the scripts is to support the following use case

## Batch mechanismes for syncronizing 

[X] Download all existing Exchange information covering: **Rooms**, **Room Policies**, **Room List**, Room Delegate (TODO), Distribution Lists (TODO) supporting delegation and place information

[X] Analyse downloaded data with the purpose of generating "slave" files

[X] Extract data from SharePoint containing the list defining the **Room**, **Room metadata** structure and **Room controlling** data structures.

[X] Build "master" files from those

[x] Compare "master" with "slaves" in order to produce a setup of files containing deltas, what is missing in slave, what is missing in master and which matching items have difference on an attributes

[x] Ability to execure Create, Update and Delete operation on SharePoint List / Exchange items respectively.

[X] Deploy scripts to Azure Function

[x] Execute and monitor Azure Function


## Initial load of data from Exchange into SharePoint

## Ongoing syncronization of data from SharePoint to Exchange


## Near online mechanisms for handling transactions
- Adding new rooms 
- **Other transactions currently not supported**

# Download all existing Exchange information 

## get-rooms-policies-places-exchange.ps1
First few lines - basically create an array of room with the email of each room as members, and for each member 3 properties:

- mailbox
- policies
- place

```JSON
    {
        "email":  "room-dk-kb601-21a5@nets.eu",
        "mailbox":  {
                        "Alias":  "room-dk-kb601-21a5",
                        "DisplayName":  "DK-KB601-21A5 Video (6)",
                        "RecipientTypeDetails":  "RoomMailbox",
                        "MailTip":  "\u003chtml\u003e\r\n\u003cbody\u003e\r\nThis room is reserved for a project and cannot be booked\r\n\u003c/body\u003e\r\n\u003c/html\u003e\r\n"
                    },
        "policies":  {
                        
                         "AutomateProcessing":  "AutoAccept",
                         "BookingWindowInDays":  180,
                         "MaximumDurationInMinutes":  1440,
                         "AllowRecurringMeetings":  true,
                         "DeleteComments":  false,
                         "DeleteSubject":  true,
                         "AddOrganizerToSubject":  true,
                         "OrganizerInfo":  true,
                         "ResourceDelegates":  [

                                               ],
                         "RequestOutOfPolicy":  [

                                                ],
                         "AllRequestOutOfPolicy":  false,
                         "BookInPolicy":  [
                                              "/o=ExchangeLabs/ou=Exchange Administrative Group (FYDIBOHF23SPDLT)/cn=Recipients/cn=71a221d2c4c54a5aa94a1f2aa6a92a35-Room Role R"
                                          ],
                         "AllBookInPolicy":  false,
                         "RequestInPolicy":  [

                                             ],
                         "AddAdditionalResponse":  false,
                         "AdditionalResponse":  null,
                         "ProcessExternalMeetingMessages":  false

                     },
        "place":  {
                     "Street":  "",
                      "City":  "",
                      "State":  "",
                      "PostalCode":  "",
                      "CountryOrRegion":  "Denmark",
                      "GeoCoordinates":  null,
                      "Phone":  "",
                      "Capacity":  6,
                      "Building":  null,
                      "Label":  null,
                      "AudioDeviceName":  null,
                      "VideoDeviceName":  null,
                      "DisplayDeviceName":  null,
                      "IsWheelChairAccessible":  false,
                      "Floor":  null,
                      "FloorLabel":  null,
                      "Localities":  [
                                         "rooms-dk-kb601@nets.eu"
                                     ],
                      "SpaceType":  null,
                      "CustomSpaceType":  null
                  }
    },
    {
        "email":  "room-dk-kb601-21a6@nets.eu",

```

## get-roomlists-exchange.ps1

### Output: room-lists-exchange.json

First few lines - basically create an array of distribution lists 

```JSON
    {
        "email":  "rooms-dk-kb601-internal-meetings@nets.eu",
        "members":  [
                        {
                            "PrimarySmtpAddress":  "room-dk-kb601-21a6@nets.eu"
                        },
                        {
                            "PrimarySmtpAddress":  "room-dk-kb601-21c1@nets.eu"
                        },
                        {
                            "PrimarySmtpAddress":  "room-dk-kb601-21c2@nets.eu"
                        },
                        {
                            "PrimarySmtpAddress":  "room-dk-kb601-21c3@nets.eu"
                        },
                        {
                            "PrimarySmtpAddress":  "room-dk-kb601-21c4@nets.eu"
                        },
                        {
                            "PrimarySmtpAddress":  "room-dk-kb601-22d1@nets.eu"
                        },
                        {
                            "PrimarySmtpAddress":  "room-dk-kb601-22d2@nets.eu"
                        },
                        {
                            "PrimarySmtpAddress":  "room-dk-kb601-23a3@nets.eu"
                        },
                        {
                            "PrimarySmtpAddress":  "room-dk-kb601-23a4@nets.eu"
                        },
                        {
                            "PrimarySmtpAddress":  "room-dk-kb601-32b2@nets.eu"
                        },
                        {
                            "PrimarySmtpAddress":  "room-dk-kb601-32b3@nets.eu"
                        },
                        {
                            "PrimarySmtpAddress":  "room-dk-kb601-32c4@nets.eu"
                        },
                        {
                            "PrimarySmtpAddress":  "room-dk-kb601-33d1@nets.eu"
                        },
                        {
                            "PrimarySmtpAddress":  "room-dk-kb601-42c1@nets.eu"
                        },
                        {
                            "PrimarySmtpAddress":  "room-dk-kb601-42c2@nets.eu"
                        },
                        {
                            "PrimarySmtpAddress":  "room-dk-kb601-42c3@nets.eu"
                        },
                        {
                            "PrimarySmtpAddress":  "room-dk-kb601-42d1@nets.eu"
                        },
                        {
                            "PrimarySmtpAddress":  "room-dk-kb601-42d2@nets.eu"
                        },
                        {
                            "PrimarySmtpAddress":  "room-dk-kb601-42d3@nets.eu"
                        },
                        {
                            "PrimarySmtpAddress":  "room-dk-kb601-43c3@nets.eu"
                        },
                        {
                            "PrimarySmtpAddress":  "room-dk-kb601-43c4@nets.eu"
                        },
                        {
                            "PrimarySmtpAddress":  "room-dk-kb601-43c5@nets.eu"
                        }
                    ],
        "list":  {
                     "DisplayName":  "DK-KB601 Internal meetings"
                 }
    },
    {
        "email":  "rooms-dk-kb601-external-meetings@nets.eu",
        "members":  [


```

## build-raw-slavedata-from-exchange.ps1
Parse the data from room-lists-exchange.json and create "raw" files corresponding to the targetted SharePoint lists

This is a 2 step process as SharePoint list id are need to make the final files.

## build-slavedata-from-raw-files.ps1


## get-lists-sharepoint.ps1

### Output: multiple files *.sharepoint.json

- buildings.sharepoint.json
- countries.sharepoint.json
- locations.sharepoint.json
- policies.sharepoint.json
- rooms.sharepoint.json
- groups.sharepoint.json 
