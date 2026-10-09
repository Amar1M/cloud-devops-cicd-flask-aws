"""
Cloud DevOps CI/CD Flask App - Main Application
MCA Cloud & DevOps Project - Amar M S
Shows how to build production-ready Flask app for DevOps pipeline
"""
from flask import Flask, render_template, jsonify
import os
import socket
import platform
import datetime
from pathlib import Path

app = Flask(__name__)

# App metadata - injected via env vars in CI/CD
APP_VERSION = os.getenv('APP_VERSION', '1.0.0')
ENVIRONMENT = os.getenv('ENVIRONMENT', 'production')
BUILD_NUMBER = os.getenv('BUILD_NUMBER', 'local')
GIT_COMMIT = os.getenv('GIT_COMMIT', 'unknown')

def get_system_info():
    """Get system info for dashboard - useful for DevOps monitoring"""
    return {
        'hostname': socket.gethostname(),
        'platform': platform.platform(),
        'python_version': platform.python_version(),
        'cpu_count': os.cpu_count(),
        'timestamp': datetime.datetime.now().isoformat()
    }

@app.route('/')
def dashboard():
    """Main dashboard - shows deployment info"""
    system_info = get_system_info()
    deployment_info = {
        'version': APP_VERSION,
        'environment': ENVIRONMENT,
        'build_number': BUILD_NUMBER,
        'git_commit': GIT_COMMIT[:7] if len(GIT_COMMIT) > 7 else GIT_COMMIT,
        'deployed_at': datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S IST'),
        'region': os.getenv('AWS_REGION', 'ap-south-1')
    }
    return render_template('index.html', system=system_info, deployment=deployment_info)

@app.route('/health')
def health():
    """Health check endpoint - Used by load balancers & monitoring"""
    return jsonify({
        'status': 'healthy',
        'version': APP_VERSION,
        'environment': ENVIRONMENT,
        'timestamp': datetime.datetime.utcnow().isoformat(),
        'uptime': 'running'
    }), 200

@app.route('/api/info')
def api_info():
    """API endpoint returning app and system info"""
    return jsonify({
        'app': {
            'name': 'cloud-devops-cicd-flask-aws',
            'version': APP_VERSION,
            'environment': ENVIRONMENT,
            'build': BUILD_NUMBER,
            'commit': GIT_COMMIT
        },
        'system': get_system_info(),
        'endpoints': [
            {'path': '/', 'method': 'GET', 'description': 'Dashboard'},
            {'path': '/health', 'method': 'GET', 'description': 'Health check'},
            {'path': '/api/info', 'method': 'GET', 'description': 'System info API'},
            {'path': '/api/resume-skills', 'method': 'GET', 'description': 'Demo API - skill matcher'}
        ]
    })

@app.route('/api/resume-skills')
def resume_skills():
    """Demo API - shows your Python + DevOps skills (reuses your Resume Analyzer logic)"""
    skills = {
        'cloud_devops': ['AWS EC2', 'S3', 'IAM', 'VPC', 'Docker', 'Kubernetes (basics)', 'GitHub Actions', 'Terraform (basics)', 'Linux', 'Bash', 'Nginx', 'Prometheus', 'Grafana'],
        'backend': ['Python', 'FastAPI', 'Flask', 'REST APIs', 'SQL', 'Git'],
        'deployment': {
            'ci_cd': 'GitHub Actions → Docker Hub → AWS EC2',
            'containerization': 'Multi-stage Docker build (85% size reduction)',
            'infra': 'Terraform ready, Nginx reverse proxy',
            'monitoring': 'Health endpoint for load balancer'
        }
    }
    return jsonify(skills)

# Error handlers - production ready
@app.errorhandler(404)
def not_found(e):
    return jsonify({'error': 'Not found', 'path': str(e)}), 404

@app.errorhandler(500)
def internal_error(e):
    return jsonify({'error': 'Internal server error', 'message': str(e)}), 500

if __name__ == '__main__':
    port = int(os.getenv('PORT', 5000))
    # For production use gunicorn, for local use flask dev server
    app.run(host='0.0.0.0', port=port, debug=False)
