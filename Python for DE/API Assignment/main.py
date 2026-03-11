# main.py
import schedule
import time
from database import setup_tables, seed_users, seed_posts
from error_handler import fetch_data
from scheduler import scheduled_task

def main():
    print("[INIT] Setting up database tables...")
    setup_tables()

    print("[INIT] Fetching and seeding initial users...")
    users = fetch_data("users")
    if users:
        seed_users(users)

    print("[INIT] Fetching and seeding initial posts...")
    posts = fetch_data("posts")
    if posts:
        seed_posts(posts)

    scheduled_task()
    schedule.every(10).minutes.do(scheduled_task)

    print("\n[SCHEDULER] Running every 10 minutes. Press Ctrl+C to stop.\n")
    while True:
        schedule.run_pending()
        time.sleep(1)

if __name__ == "__main__":
    main()