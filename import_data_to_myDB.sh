
set -e  # Stop on first error so students see exactly which step failed


DATA_DIR="./data"
PG="PG:host=localhost port=5432 dbname=gis user=gis password=gis"


echo ""
echo "⏳ Checking PostGIS connection..."
for i in $(seq 1 10); do
    if docker compose exec -T -e PGPASSWORD=gis postgis pg_isready -h localhost -U gis -d berlin > /dev/null 2>&1; then
        echo "✅ PostGIS is ready"
        break
    fi
    if [ "$i" -eq 10 ]; then
        echo "❌ ERROR: Could not connect to PostGIS after 10 attempts."
        echo "   Make sure the container is running: docker compose up -d"
        exit 1
    fi
    echo "   Waiting for PostGIS... (attempt $i/10)"
    sleep 3
done
# --- Load data into PostGIS --------------------------------------
echo "👀 👀 👀"
echo "📤 Loading data into PostGIS..."
# -nln        = set the table name
# -lco        = layer creation options
# -overwrite  = replace table if it already exists (safe for re-runs)
# -s_srs/-t_srs = source and target coordinate systems (both WGS84)
ogr2ogr \
    -f "PostgreSQL" \
    "$PG" \
    "$DATA_DIR/neighborhoods_berlin.geojson" \
    -nln neighborhoods_berlin \
    -overwrite \
    -lco GEOMETRY_NAME=wkb_geometry \
    -lco FID=gid \
    -t_srs EPSG:3857 

echo "✅ Loaded neighborhoods_berlin table"

echo "👀 👀 👀"

ogr2ogr \
    -f "PostgreSQL" \
    "$PG" \
    "$DATA_DIR/hospital_berlin.geojson" \
    -nln hospitals_berlin \
    -overwrite \
    -lco GEOMETRY_NAME=wkb_geometry \
    -lco FID=gid \
    -t_srs EPSG:3857 

echo "✅ Loaded hospitals_berlin table"

#---verify that the data was loaded correctly------
echo ""
echo "🔍 Verifying loaded data..."
echo ""

echo "--- Neighborhood count ---"
docker compose exec -T -e PGPASSWORD=gis postgis psql -h localhost -U gis -d gis -c \
    "SELECT COUNT(*) AS neighborhood_count FROM neighborhoods_berlin ;"

echo ""
echo "--- Hospital count ---"
docker compose exec -T -e PGPASSWORD=gis postgis psql -h localhost -U gis -d gis -c \
    "SELECT COUNT(*) AS hospital_count FROM hospitals_berlin;"

echo ""
echo "--- Geometry columns ---"
docker compose exec -T -e PGPASSWORD=gis postgis psql -h localhost -U gis -d gis -c \
    "SELECT f_table_name, type, srid FROM geometry_columns ORDER BY f_table_name;"

echo ""
echo "🎉 All done! Your PostGIS database is loaded and ready."
echo "   Connect with: psql -h localhost -U gis -d gis"
echo "   Or use DBeaver/pgAdmin at localhost:5432"
