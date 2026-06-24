from flask import Flask, request, make_response
from werkzeug.middleware.proxy_fix import ProxyFix
import os
import html
import subprocess

app = Flask(__name__)

# Apply ProxyFix middleware to trust 1 level of proxy
app.wsgi_app = ProxyFix(app.wsgi_app, x_for=1)

@app.route("/")
def index():
    resp = make_response("Welcome to the insecure app!")
    # Insecure cookie: SameSite=None without Secure
    resp.set_cookie(
        "foo",
        "secret123456",
        samesite='None',
        secure=False
    )
    return resp

@app.route("/secret")
def secret():
    # Environment variable leak
    return "AWS_SECRET_ACCESS_KEY: " + os.getenv("AWS_SECRET_ACCESS_KEY", "not_set")

ALLOWED_COMMANDS = {
    "uptime": ["uptime"],
    "whoami": ["whoami"],
    "df": ["df", "-h"],
    "date": ["date"],
}

@app.route("/cmd")
def run_command():
    cmd = request.args.get("exec", "").strip()
    if not cmd:
        return "No command provided.", 400

    if cmd not in ALLOWED_COMMANDS:
        return f"Command '{cmd}' is not allowed.", 403

    try:
        result = subprocess.run(
            ALLOWED_COMMANDS[cmd],
            capture_output=True,
            text=True,
            timeout=5,
            check=False,
        )
        return result.stdout or result.stderr
    except subprocess.TimeoutExpired:
        return "Command timed out.", 504
    except Exception as e:
        return f"Unexpected error: {e}", 500

@app.route("/greet")
def greet():
    # Reflected XSS
    name = request.args.get("name", "stranger")
    return f"<h1>Hello, {name}!</h1>"

@app.route("/user")
def user_lookup():
    # Simulated SQL injection (no DB, but vulnerable logic)
    user_id = request.args.get("id", "")
    if " OR " in user_id.upper() or "=" in user_id:
        return "Access granted to all users! (simulated SQLi)"
    return f"Looking up user ID: {html.escape(user_id)}"

@app.route("/client-ip")
def client_ip():
    # Returns the client IP address, respecting X-Forwarded-For
    return f"Client IP: {request.remote_addr}"

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000)
