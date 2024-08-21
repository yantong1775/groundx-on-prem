from minio import Minio

minioClient = Minio('localhost:9000',
                    access_key='ROOTNAME',
                    secret_key='CHANGEME123',
                    secure=False)

# Make a bucket with the make_bucket API call.
try:
    minioClient.make_bucket("mybucket")
except Exception as e:
    print(e)

# list all buckets
buckets = minioClient.list_buckets()
for bucket in buckets:
    print(bucket.name, bucket.creation_date)
