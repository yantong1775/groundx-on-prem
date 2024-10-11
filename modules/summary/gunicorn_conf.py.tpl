infolog = "-"
accesslog = "-"
errorlog = "-"

loglevel = "info"
workers = ${workers}
threads = ${threads}
timeout = 180

worker_class = "uvicorn.workers.UvicornWorker"

bind = "0.0.0.0:8080"

wsgi_app = "summary_server:app"