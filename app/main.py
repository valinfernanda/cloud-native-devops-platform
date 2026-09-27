from fastapi import FastAPI
from pydantic import BaseModel
from prometheus_fastapi_instrumentator import Instrumentator

app = FastAPI(title="Task Management API")

Instrumentator().instrument(app).expose(app)



class Task(BaseModel):
    title: str
    completed: bool = False


tasks = []


@app.get("/")
def root():
    return {
        "message": "Task Management API is running"
    }


@app.get("/health")
def health():
    return {
        "status": "healthy"
    }


@app.get("/tasks")
def get_tasks():
    return tasks


@app.post("/tasks")
def create_task(task: Task):
    new_task = {
        "id": len(tasks) + 1,
        "title": task.title,
        "completed": task.completed
    }

    tasks.append(new_task)

    return new_task