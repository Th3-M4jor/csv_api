# CsvApi
Implementation of a simple API for uploading a CSV file and manipulating it.

Expects a CSV file with the following columns in the following order:
- `Region`: The region name
- `Country`: The country name
- `Item Type`: The item type
- `Sales Channel`: The sales channel (`Online`, `Offline`)
- `Order Priority`: The order priority
- `Order Date`: The order date (format: `MM/DD/YYYY`)
- `Order ID`: The order ID
- `Ship Date`: The ship date (format: `MM/DD/YYYY`)
- `Units Sold`: The units sold
- `Unit Price`: The unit price
- `Unit Cost`: The unit cost
- `Total Revenue`: The total revenue
- `Total Cost`: The total cost
- `Total Profit`: The total profit

When uploading a CSV file a header row is assumed to be present, unless the optional query parameter `header` is set to `false`.

To build the Docker container, run `docker build -t csv-api .`

To start the container then run `docker run -p 5000:5000 csv-api`

The API should then be accessible at `http://localhost:5000/`


## Endpoints
- `PUT /api/csv/`
  - Upload a CSV file, replaces any existing Data
- `POST /api/csv/`
  - Upload a CSV file, appends to existing Data
- `DELETE /api/region/data/`
  - Deletes all orders in a region.
  - Requires a JSON body with a `name` key.
  - Countries and Regions are not deleted.
- `PATCH /api/region/channel/`
  - Updates a channel for a region.
  - Requires a JSON body with keys for `name` and `channel`.
- `GET /api/order/:id`
  - Get a JSON of the order for the given id.
- `GET /api/orders`
  - Get a JSON of all orders, ordered by region then country then order ID.

### Notes
 - When duplicate order IDs are given in a CSV, the last one will be kept.