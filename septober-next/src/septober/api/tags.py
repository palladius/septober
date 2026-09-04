from fastapi import APIRouter, Depends, HTTPException
from sqlmodel import Session, select
from typing import List
from septober.models import Tag, TodoTagLink, Todo
from septober.schemas import TagRead, TagCreate
from septober.db import get_session

router = APIRouter(prefix="/api/tags", tags=["tags"])

@router.get("/", response_model=List[TagRead])
def list_tags(session: Session = Depends(get_session)):
    tags = session.exec(select(Tag)).all()
    return tags

@router.post("/", response_model=TagRead)
def create_tag(tag_in: TagCreate, session: Session = Depends(get_session)):
    tag = session.exec(select(Tag).where(Tag.name == tag_in.name)).first()
    if tag:
        return tag
    tag = Tag(name=tag_in.name)
    session.add(tag)
    session.commit()
    session.refresh(tag)
    return tag

@router.get("/{tag_id}", response_model=TagRead)
def get_tag(tag_id: int, session: Session = Depends(get_session)):
    tag = session.get(Tag, tag_id)
    if not tag:
        raise HTTPException(status_code=404, detail="Tag not found")
    return tag

@router.delete("/{tag_id}", status_code=204)
def delete_tag(tag_id: int, session: Session = Depends(get_session)):
    tag = session.get(Tag, tag_id)
    if not tag:
        raise HTTPException(status_code=404, detail="Tag not found")
    
    links = session.exec(select(TodoTagLink).where(TodoTagLink.tag_id == tag_id)).all()
    for link in links:
        session.delete(link)
        
    session.delete(tag)
    session.commit()
