from fastapi import APIRouter, Depends
from sqlmodel import Session
from pydantic import BaseModel
from typing import List
from septober.schemas import BulkIngestRequest, BulkIngestResponse, TodoCreate
from septober.db import get_session
from septober.api.todos import create_todo

router = APIRouter(prefix="/api/ingest", tags=["ingest"])

class TextIngestRequest(BaseModel):
    text: str

@router.post("/", response_model=BulkIngestResponse)
def ingest_bulk(request: BulkIngestRequest, session: Session = Depends(get_session)):
    created = 0
    errors = []
    
    for item in request.items:
        try:
            create_todo(item, session=session)
            created += 1
        except Exception as e:
            errors.append(f"Error processing item '{item.title}': {str(e)}")
            
    return BulkIngestResponse(created_count=created, errors=errors)

@router.post("/text", response_model=BulkIngestResponse)
def ingest_text(request: TextIngestRequest, session: Session = Depends(get_session)):
    created = 0
    errors = []
    
    lines = [line.strip() for line in request.text.split("\n") if line.strip()]
    for line in lines:
        try:
            todo_in = TodoCreate(title=line)
            create_todo(todo_in, session=session)
            created += 1
        except Exception as e:
            errors.append(f"Error processing line '{line}': {str(e)}")
            
    return BulkIngestResponse(created_count=created, errors=errors)
