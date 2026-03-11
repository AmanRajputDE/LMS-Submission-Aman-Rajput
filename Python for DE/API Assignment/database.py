import psycopg2 as pg
from psycopg2.extras import execute_values
from dotenv import load_dotenv
import os

load_dotenv()

def get_connection():
    return pg.connect(
        host = os.getenv("DB_HOST"),
        port = os.getenv("DB_PORT"),
        dbname = os.getenv("DB_NAME"),
        user = os.getenv("DB_USER"),
        password = os.getenv("DB_PASSWORD")
    )

def setup_tables():
    conn = get_connection()
    cur = conn.cursor()

    cur.execute("""
    create table if not exists users(
        id integer primary key,
        name text not null,
        email text not null,
        address text
    );
    """)

    cur.execute("""
    create table if not exists posts(
        id integer primary key,
        user_id integer references users(id),
        title text not null,
        body text
    );
    """)

    conn.commit()
    cur.close()
    conn.close()
    print("[DB] Tables are ready.")

def seed_users(users):
    if not users:
        return 
    
    records = []
    for u in users:
        addr = u.get("address",{})
        address_str = ( 
            f"{addr.get('street', '')}, {addr.get('suite', '')}, "
            f"{addr.get('city', '')}, {addr.get('zipcode', '')}"
            )
        records.append((u["id"], u["name"], u["email"], address_str))

    conn = get_connection()
    cur = conn.cursor()

    execute_values(cur,"""
        INSERT INTO users (id, name, email, address)
        VALUES %s
        ON CONFLICT (id) DO NOTHING
    """, records)

    conn.commit()
    cur.close()
    conn.close()
    print(f"[DB] Seeded {len(records)} users (duplicates skipped).")
    
def seed_posts(posts):
    if not posts:
        return 0
    
    records = [(p["id"], p["userId"], p["title"], p["body"]) for p in posts]

    conn = get_connection()
    cur = conn.cursor()

    inserted = 0

    for record in records:
        cur.execute("""
            INSERT INTO posts (id, user_id, title, body)
            VALUES (%s, %s, %s, %s)
            ON CONFLICT (id) DO NOTHING
        """, record)
        inserted += cur.rowcount

    conn.commit()
    cur.close()
    conn.close()
    return inserted

def get_counts():
    conn = get_connection()
    cur = conn.cursor()
    cur.execute("select count(*) from users;")
    total_users = cur.fetchone()[0]
    cur.execute("select count(*) from posts;")
    total_posts = cur.fetchone()[0]
    cur.close()
    conn.close()
    return total_users, total_posts

