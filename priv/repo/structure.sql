CREATE TABLE IF NOT EXISTS "schema_migrations" ("version" INTEGER PRIMARY KEY, "inserted_at" TEXT_DATETIME);
CREATE TABLE IF NOT EXISTS "region" ("id" INTEGER PRIMARY KEY, "name" TEXT NOT NULL);
CREATE TABLE IF NOT EXISTS "country" ("id" INTEGER PRIMARY KEY, "name" TEXT NOT NULL, "region_id" INTEGER CONSTRAINT "country_region_id_fkey" REFERENCES "region"("id") ON DELETE CASCADE ON UPDATE CASCADE);
CREATE TABLE IF NOT EXISTS "order" ("id" INTEGER PRIMARY KEY, "type" TEXT NOT NULL, "sales_channel" TEXT NOT NULL, "order_priority" TEXT NOT NULL, "order_date" DATE NOT NULL, "ship_date" DATE NOT NULL, "units_sold" INTEGER NOT NULL, "unit_price" DECIMAL NOT NULL, "unit_cost" DECIMAL NOT NULL, "total_revenue" DECIMAL NOT NULL, "total_cost" DECIMAL NOT NULL, "country_id" INTEGER CONSTRAINT "order_country_id_fkey" REFERENCES "country"("id") ON DELETE CASCADE ON UPDATE CASCADE);
INSERT INTO schema_migrations VALUES(20220209214114,'2022-02-09T23:37:59');
