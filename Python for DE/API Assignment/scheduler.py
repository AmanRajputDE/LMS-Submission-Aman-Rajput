import schedule
import time
import logging
from datetime import datetime
from error_handler import fetch_data
from database import seed_posts, get_counts

logging.basicConfig(
    filename='api_errors.log',
    level=logging.INFO,
    format='%(asctime)s | %(levelname)s | %(message)s',
    datefmt='%Y-%m-%d %H:%M:%S'
)
logger = logging.getLogger(__name__)

def scheduled_task():
    print(f"\n[SCHEDULER] Running task at {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    try:
        posts = fetch_data("posts")

        if posts is None:
            raise RuntimeError("Failed to fetch posts — API returned None.")

        new_count = seed_posts(posts)

        logger.info(f"Scheduled task complete | new_posts_added={new_count}")
        print_summary(new_count)

    except Exception as e:
        logger.error(f"SchedulerError | {type(e).__name__} | {str(e)}")
        print(f"[ERROR] Scheduled task failed. See api_errors.log.")

def print_summary(new_posts: int):
    total_users, total_posts = get_counts()
    print("=" * 45)
    print("         SUMMARY REPORT")
    print("=" * 45)
    print(f"  Total users in DB   : {total_users}")
    print(f"  Total posts in DB   : {total_posts}")
    print(f"  New posts this run  : {new_posts}")
    print("=" * 45)