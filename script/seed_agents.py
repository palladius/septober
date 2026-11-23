import pymysql
import bcrypt
import datetime

agents = [
    {
        "username": "rcarlesso.ermete",
        "email": "palladiusbonton+ermete@gmail.com",
        "password": b"septober-ermete-2026",
        "parent_id": 10,
        "is_agent": 1,
        "agent_host": "mini-lobby",
        "agent_icon": "🚛"
    },
    {
        "username": "rcarlesso.lobby",
        "email": "palladiusbonton+lobby@gmail.com",
        "password": b"septober-lobby-2026",
        "parent_id": 10,
        "is_agent": 1,
        "agent_host": "mini-lobby",
        "agent_icon": "🦞"
    },
    {
        "username": "rcarlesso.pux",
        "email": "palladiusbonton+pux@gmail.com",
        "password": b"septober-pux-2026",
        "parent_id": 10,
        "is_agent": 1,
        "agent_host": "openclaw",
        "agent_icon": "🐾"
    }
]

conn = pymysql.connect(
    host="35.198.182.127",
    user="septoberuser",
    password="comeDirebbeIlBergonz",
    database="septober",
    charset="utf8mb4",
    connect_timeout=10,
    autocommit=True
)

now = datetime.datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S")

with conn.cursor() as cur:
    for a in agents:
        uname = a["username"]
        cur.execute("SELECT id FROM users WHERE username = %s;", (uname,))
        existing = cur.fetchone()
        salt = bcrypt.gensalt(rounds=10, prefix=b"2a")
        phash = bcrypt.hashpw(a["password"], salt)
        salt_str = salt.decode("ascii")
        hash_str = phash.decode("ascii")

        if existing:
            agent_id = existing[0]
            print(f"Updating existing agent {uname} (ID {agent_id})...")
            cur.execute("""
                UPDATE users 
                SET email=%s, password_salt=%s, password_hash=%s, parent_id=%s, is_agent=%s, agent_host=%s, agent_icon=%s, updated_at=%s
                WHERE id=%s;
            """, (a["email"], salt_str, hash_str, a["parent_id"], a["is_agent"], a["agent_host"], a["agent_icon"], now, agent_id))
        else:
            print(f"Inserting new agent {uname}...")
            cur.execute("""
                INSERT INTO users (username, email, password_salt, password_hash, parent_id, is_agent, agent_host, agent_icon, created_at, updated_at)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s);
            """, (uname, a["email"], salt_str, hash_str, a["parent_id"], a["is_agent"], a["agent_host"], a["agent_icon"], now, now))

    print("\n--- Current Family of rcarlesso (ID 10) ---")
    cur.execute("SELECT id, username, email, parent_id, is_agent, agent_host, agent_icon FROM users WHERE id=10 OR parent_id=10;")
    for row in cur.fetchall():
        print(row)

conn.close()
