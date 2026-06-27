# Berlin Hospital Density Analysis

This project analyzes Berlin hospital locations and neighborhood boundaries using Python geospatial tools. It demonstrates exploratory spatial analysis, visualization, export to GeoParquet, PostGIS integration, and DuckDB querying of both local and remote geospatial data.

## What this project does

- Loads Berlin hospitals and neighborhoods from GeoJSON files
- Renames and inspects geospatial attributes with `geopandas`
- Maps hospitals on Berlin neighborhoods
- Performs a spatial join to count hospitals in each neighborhood
- Computes hospital density per square kilometer
- Exports the result to a GeoParquet file
- Connects to PostGIS using `SQLAlchemy` and runs spatial SQL queries
- Uses DuckDB to query the exported GeoParquet locally
- Demonstrates remote S3 queries via DuckDB and Overture Maps data

## Key files

- `hospital_density.ipynb` - main analysis notebook
- `docker-compose.yml` - PostGIS container definition
- `import_data_to_myDB.sh` - script to import GeoJSON files into PostGIS using `ogr2ogr`
- `data/hospital_berlin.geojson` - hospital point dataset
- `data/neighborhoods_berlin.geojson` - Berlin neighborhood polygon dataset

## Requirements

Install the Python dependencies before running the notebook.

```bash
pip install geopandas fiona matplotlib sqlalchemy pandas duckdb pyarrow
```

You also need:

- Docker and Docker Compose (for PostGIS)
- `ogr2ogr` from GDAL (used by `import_data_to_myDB.sh`)

## Running the analysis

1. Open `hospital_density.ipynb` in Jupyter or VS Code.
2. Run cells in order.
3. The notebook performs:
   - GeoJSON import and data inspection
   - neighborhood visualization and hospital overlay
   - spatial join and hospital count aggregation
   - density calculation and choropleth mapping
   - GeoParquet export
   - PostGIS query and mapping
   - DuckDB local query over GeoParquet
   - DuckDB remote S3 query for Overture Maps data

## PostGIS setup

Start the PostGIS container:

```bash
docker compose up -d
```

Verify PostGIS is available on `localhost:5432`.

Then load the data into PostGIS using:

```bash
bash import_data_to_myDB.sh
```

This script loads:

- `neighborhoods_berlin.geojson` → `neighborhoods_berlin`
- `hospital_berlin.geojson` → `hospitals_berlin`

## DuckDB and GeoParquet

The notebook exports a GeoParquet file named:

- `berlin_neighborhood_hospital_density.parquet`

DuckDB reads this file directly and runs SQL analytics without a separate database server.

## Remote S3 queries

The notebook also demonstrates DuckDB querying remote Overture Maps Parquet files from S3. This example shows how to read building and place data directly from a cloud dataset without downloading everything first.

## Notes

- The notebook uses Berlin datasets and assumes EPSG:3857 geometry for spatial calculations.
- The PostGIS section expects a local database named `gis` with user `gis` and password `gis`.
- If you want to adjust the bounding box or dataset path, edit the corresponding notebook cells.

## License

This repository includes its own `LICENSE` file.
