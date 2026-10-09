import sys
import os
sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)))

from app import app

def test_health_endpoint():
    client = app.test_client()
    response = client.get('/health')
    assert response.status_code == 200
    data = response.get_json()
    assert data['status'] == 'healthy'

def test_api_info():
    client = app.test_client()
    response = client.get('/api/info')
    assert response.status_code == 200
    data = response.get_json()
    assert 'app' in data
    assert 'system' in data

def test_homepage():
    client = app.test_client()
    response = client.get('/')
    assert response.status_code == 200
    assert b'Cloud DevOps' in response.data

def test_resume_skills():
    client = app.test_client()
    response = client.get('/api/resume-skills')
    assert response.status_code == 200
    data = response.get_json()
    assert 'cloud_devops' in data
