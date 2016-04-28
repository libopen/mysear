der = csv.reader(open("job_history.csv", "r"))
>>> lines = []
>>> for line in reader:
...   lines.append(line)
...
>>> cursor.execute("ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD HH24:MI:SS'")
>>> cursor.executemany("INSERT INTO job_his VALUES(:1,:2,:3,:4,:5)", lines)
>>> db.commit()
