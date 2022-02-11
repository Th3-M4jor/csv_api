# CsvApi
Coding Challenge for ICO Parnters

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