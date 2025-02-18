curl -X POST http://127.0.0.1:8000/api/users/ \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzM5NTUyMTM0LCJpYXQiOjE3Mzk1NDg1MzQsImp0aSI6IjEzYWNmYTliMDRmZDRkMmI5OWZkZTAyNjNmYTkyODNiIiwidXNlcl9pZCI6MX0.YtbuWs86IkiBt0pDD_YFMWe4YvsMcom2FgHfB_QDeQE" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "prakash",
    "email": "pdhrutaraj@gmail.com",
    "password": "prakash",
    "first_name": "Prakash",
    "last_name": "Dhrutaraj"
  }'

