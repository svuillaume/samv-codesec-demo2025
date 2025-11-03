from flask import Flask, request, make_response
from werkzeug.middleware.proxy_fix import ProxyFix
import os
import html

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

@app.route("/cmd")
def run_command():
    # Remote code execution
    cmd = request.args.get("exec")
    if cmd:
        return os.popen(cmd).read()
    return "No command provided."

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
