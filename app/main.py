import logging
import os
from pathlib import Path

import psycopg
from fastapi import FastAPI, HTTPException
from fastapi.responses import FileResponse
from psycopg.rows import dict_row


logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("orders-api")

app = FastAPI(title="Orders API", version="1.0.0")
static_directory = Path(__file__).parent / "static"


def database_connection() -> psycopg.Connection:
    return psycopg.connect(
        host=os.environ["DATABASE_HOST"],
        port=int(os.getenv("DATABASE_PORT", "5432")),
        dbname=os.environ["DATABASE_NAME"],
        user=os.environ["DATABASE_USER"],
        password=os.environ["DATABASE_PASSWORD"],
        connect_timeout=3,
        row_factory=dict_row,
    )


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok"}


@app.get("/", include_in_schema=False)
def orders_console() -> FileResponse:
    return FileResponse(static_directory / "index.html")


@app.get("/orders")
def list_orders() -> list[dict[str, object]]:
    try:
        with database_connection() as connection:
            with connection.cursor() as cursor:
                cursor.execute(
                    "SELECT id, customer, item, quantity FROM orders ORDER BY id"
                )
                return list(cursor.fetchall())
    except (psycopg.Error, OSError) as error:
        logger.exception("Unable to load orders from PostgreSQL")
        raise HTTPException(status_code=500, detail="Unable to load orders") from error
