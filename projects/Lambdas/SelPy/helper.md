# Compress and encode to B64
tar -zcv deploy.sh lambda_function.py | openssl base64 > pack.tgz.b64

# Convert from B64 to Gzipped Tar
cat Pack.tgz.b64 | openssl base64 -d > Pack.tgz


# Convert from B64 to Gzipped Tar and extract it
cat Pack.tgz.b64 | openssl base64 -d | tar -zxv
