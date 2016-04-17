# Getting Started

TFL API Client has been designed to be as simple as possible to work with.

This Getting Started guide will cover basic usage of the gem, however for a 
more in depth guide, checkout the [docs][docs].

[docs]: http://www.rubydoc.info/github/LukeHackett/tfl_api_client


## BikePoint

The bike point interface interacts with the /BikePoint end point upon the 
TFL API. This end point will return information regarding the [Santander 
Cycle hire][cycle_hire] docking stations, including 5 minute real-time bike 
and docking station status information.

[cycle_hire]: https://tfl.gov.uk/modes/cycling/santander-cycles


### Obtain an individual BikePoint  

Information upon an individual BikePoint can be obtained using the `location` 
method, whilst also passing the ID of the BikePoint.

```ruby
client = TflApi::Client.new(app_id: YOUR_TFL_APP_ID, app_key: YOUR_TFL_APP_KEY)
client.bike_point.location

=>  {
      "id":"BikePoints_10",
      "url": "https://api-prod5.tfl.gov.uk/Place/BikePoints_10",
      "commonName": "Park Street, Bankside",
      "placeType": "BikePoint",
      "additionalProperties": [],
      "children":[],
        "childrenUrls": [],
      "lat":51.505974,
      "lon":-0.092754
    }   
```

### Obtain all BikePoint locations 

In order to obtain all BikePoint locations and their details the `locations`
method can be used.

```ruby
client = TflApi::Client.new(app_id: YOUR_TFL_APP_ID, app_key: YOUR_TFL_APP_KEY)
client.bike_point.locations

=>  [
      {
        "id":"BikePoints_10",
        "url": "https://api-prod5.tfl.gov.uk/Place/BikePoints_10",
        "commonName": "Park Street, Bankside",
        "placeType": "BikePoint",
        "additionalProperties": [],
        "children":[],
        "childrenUrls": [],
        "lat":51.505974,
        "lon":-0.092754
      },
      ...
      // Additional Locations
      ...
    ]
```        


### Obtain all BikePoint locations within a locus

In order to obtain all BikePoint locations within a given locus the 
`locations_within_locus` method should be used. In this context, a locus is a 
particular position given by the longitude and latitude values with an area 
that is calculated in accordance to the given radius in metres.

```ruby
client = TflApi::Client.new(app_id: YOUR_TFL_APP_ID, app_key: YOUR_TFL_APP_KEY)
client.bike_point.locations_within_locus(51.5007292, -0.1246254, 500)

=>  {
      "centrePoint": [
        51.5, -0.124
      ],
      "places": [
        {
          "additionalProperties": [],
          "children": [],
          "commonName": "Abingdon Green, Westminster",
          "distance": 298.0259124357908,
          "id": "BikePoints_583",
          "lat": 51.497622,
          "lon": -0.125978,
          "placeType": "BikePoint",
          "url": "https://api-prod6.tfl.gov.uk/Place/BikePoints_583",
        }
        ...
        // Additional Locations
        ...
      ]
    }
```      


### Obtain all BikePoint locations within a bounding box

In order to obtain all BikePoint locations within a given square the 
`locations_within_bounding_box` method should be used. Each of the coordinate
pairs are used to draw a bounding box, to which all BikePoint locations within
the box are returned.

```ruby
client = TflApi::Client.new(app_id: YOUR_TFL_APP_ID, app_key: YOUR_TFL_APP_KEY)
client.bike_point.locations_within_bounding_box(51.5138453, -0.0983506, 51.5007292, -0.1246254)

=>  [
      {
        "additionalProperties": [],
        "children": [],
        "commonName": "Godliman Street, St. Paul's",
        "id": "BikePoints_48",
        "lat": 51.512484,
        "lon": -0.099141,
        "placeType": "BikePoint",
        "url": "https://api-prod6.tfl.gov.uk/Place/BikePoints_48"
      }
      ...
      // Additional Locations
      ...
    ]
```


### Search for a given BikePoint location

The TFL API supports searching for BikePoint locations and will search within
the "commonName" field. To search for a given location the `search` method 
accepts a query String.

```ruby
client = TflApi::Client.new(app_id: YOUR_TFL_APP_ID, app_key: YOUR_TFL_APP_KEY)
client.bike_point.search("St. James's")

=>  [
      {
        "id": "BikePoints_160",
        "url": "https: //api-prod6.tfl.gov.uk/Place/BikePoints_160",
        "commonName": "Waterloo Place, St. James's",
        "placeType": "BikePoint",
        "additionalProperties": [],
        "children": [],
        "childrenUrls": [],
        "lat": 51.506633,
        "lon": -0.131773
      }
      ...
      // Additional Locations
      ...
    ]
```


## Cycle Superhighway

The cycle superhighway interface interacts with the /CycleSuperhighway 
end point upon the TFL API. This end point will return information 
regarding the [Cycle Superhighways][cycle_superhighways] locations, 
including coordinates of the route.

[cycle_superhighways]: https://tfl.gov.uk/modes/cycling/routes-and-maps/cycle-superhighways

### Obtain all Cycle Superhighways routes

In order to obtain all Cycle Superhighway routes and their details the 
`superhighways` method can be used.

```ruby
client = TflApi::Client.new(app_id: YOUR_TFL_APP_ID, app_key: YOUR_TFL_APP_KEY)
client.cycle.superhighways

=>  [
      {
        'id': 'CS-1',
        'label': 'CS Route 1',
        'labelShort': 'CS-1',
        'segmented': true,
        'geography': {
          'type': 'LineString',
          'coordinates': [],
          'crs': {
            'type': 'name',
            'properties': {
              'name': 'ABC:1234'
            }
          }
        }
      }
      ...
      // Additional Cycle Superhighways
      ...
    ]
```

### Obtain an individual Cycle Superhighway routes

Information upon an individual Cycle Superhighway can be obtained using
the `superhighway` method, whilst passing the ID of the Cycle 
Superhighway route.

```ruby
client = TflApi::Client.new(app_id: YOUR_TFL_APP_ID, app_key: YOUR_TFL_APP_KEY)
client.cycle.superhighway('CS-1')

=>  {
      'id': 'CS-1',
      'label': 'CS Route 1',
      'labelShort': 'CS-1',
      'segmented': true,
      'geography': {
        'type': 'LineString',
        'coordinates': [],
        'crs': {
          'type': 'name',
          'properties': {
            'name': 'ABC:1234'
          }
        }
      }
    }
```
