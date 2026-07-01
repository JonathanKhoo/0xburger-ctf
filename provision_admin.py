"""
Admin Provisioning Script for 0xBURGER Website
===============================================
Usage:
  python provision_admin.py

Requirements:
  pip install supabase

Environment variables (set before running):
  SUPABASE_URL=https://YOUR_PROJECT.supabase.co
  SUPABASE_SERVICE_ROLE_KEY=<service role secret from Supabase Dashboard > Settings > API>

This creates an admin user with app_metadata.role='admin'.
The admin user CANNOT be created via the public website sign-up.
"""
import os
import sys
from supabase import create_client

url = os.environ.get("SUPABASE_URL")
service_key = os.environ.get("SUPABASE_SERVICE_ROLE_KEY")

if not url or not service_key:
    print("ERROR: Set SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY environment variables.")
    print("Find it at: Supabase Dashboard > Settings > API > service_role secret")
    sys.exit(1)

admin_client = create_client(url, service_key)

email = input("Admin email: ").strip()
password = input("Admin password (min 6 chars): ").strip()

if not email or not password:
    print("ERROR: Email and password required.")
    sys.exit(1)

if len(password) < 6:
    print("ERROR: Password must be at least 6 characters.")
    sys.exit(1)

try:
    resp = admin_client.auth.admin.create_user({
        "email": email,
        "password": password,
        "email_confirm": True,
        "app_metadata": {"role": "admin"}
    })
    print(f"\nAdmin provisioned: {resp.user.id}")
    print(f"Email: {resp.user.email}")
    print(f"Role:  {resp.user.app_metadata.get('role')}")
    print("\nYou can now sign in at https://jonathankhoo.github.io/0xburger-ctf/")
except Exception as e:
    print(f"ERROR: {e}")
    sys.exit(1)
