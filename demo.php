<?php
// Hardcoded secrets (bad practice)
$password = "P@ssw0rd123!";
$api_secret = "demo_51H8SecretKeyInPlainText";

// Set insecure cookie with sensitive data
setcookie("session_token", "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.fakejwt", time() + 3600, "/");

// Optional: another cookie with secret
setcookie("api_key", "abc56789-fake-api-key", time() + 3600, "/");

// Output
echo "<h1>Welcome to Insecure PHP App</h1>";
echo "<p>Your password is: <strong>$password</strong></p>";
echo "<p>Your API secret is: <strong>$api_secret</strong></p>";

// Show token via URL param
if (isset($_GET['show_token']) && $_GET['show_token'] === 'yes') {
    echo "<p>Token: <strong>ghp_abc123FakeGitHubToken</strong></p>";
}
?>
