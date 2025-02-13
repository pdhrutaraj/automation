
curl -X PUT http://127.0.0.1:8000/api/users/3/ \
  -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzM5MzU4MjA3LCJpYXQiOjE3MzkzNTQ2MDcsImp0aSI6ImM5YzM2NjVhMDU5ZTQ4ZDhiNzUzNDYwNWIwNWEyZDBiIiwidXNlcl9pZCI6MX0.BozdnXB5bNXlES98aGRk5GpBzCOpVBHoh6ahasx54Ww" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "newuser",
    "email": "newuser@example.com",
    "first_name": "UpdatedFirstName",
    "last_name": "UpdatedLastName",
    "is_staff": false,
    "is_active": true
  }'

