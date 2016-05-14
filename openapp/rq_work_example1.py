from rq_job_example1 import count_words_at_url
from redis import Redis
from rq import Queue
redis_conn = Redis('10.96.142.109',6380)
q = Queue(connection = redis_conn)
