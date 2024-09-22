
[program:celery_worker_${worker_number}]
command=celery -A document.celery_process.app worker --loglevel=INFO --queues=layout_queue --concurrency=1
autostart=true
autorestart=true
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0