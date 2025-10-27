"""
Database inspection endpoints for admin users.
"""

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import MetaData, Table, inspect, select
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.orm import Session

from src import models
from src.database import engine, get_db
from src.dependencies import get_current_user, require_admin

router = APIRouter(prefix="/db")


@router.get("/tables", tags=["User - Database"])
def get_database_tables(
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """
    Get list of all tables in the database.
    Available to all authenticated users - shows table names only, not data.
    """
    try:
        inspector = inspect(engine)
        table_names = inspector.get_table_names()
        return {"tables": table_names}
    except SQLAlchemyError as e:
        raise HTTPException(500, f"Database error: {e!s}")


@router.get("/tables/{table_name}", tags=["Admin - Database"])
def get_table_data(
    table_name: str,
    admin: models.User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    """
    Get all data from a specific table.
    Admin access required - returns actual row data.
    """
    try:
        # Verify table exists
        inspector = inspect(engine)
        table_names = inspector.get_table_names()

        if table_name not in table_names:
            raise HTTPException(404, f"Table '{table_name}' not found")

        # Get column information
        columns_info = inspector.get_columns(table_name)
        column_names = []
        for col in columns_info:
            column_names.append(col["name"])

        # Get all rows - Parameterization to avoid SQL injection
        metadata = MetaData()
        table = Table(table_name, metadata, autoload_with=engine)
        result = db.execute(select(table))
        rows = result.fetchall()

        # Convert rows to dictionaries
        row_dicts = []
        for row in rows:
            row_dict = {}
            for i, col_name in enumerate(column_names):
                row_dict[col_name] = row[i]
            row_dicts.append(row_dict)

        return {
            "table_name": table_name,
            "columns": column_names,
            "rows": row_dicts,
        }

    except SQLAlchemyError as e:
        raise HTTPException(500, f"Database error: {e!s}")
