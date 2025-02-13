curl -X PATCH http://127.0.0.1:8000/api/users/3/ \
  -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzM5MzU3OTA1LCJpYXQiOjE3MzkzNTQzMDUsImp0aSI6IjE0NDg4MmVlN2FkYjQ1MWE4MTRiNzZlM2E2NzllMjc3IiwidXNlcl9pZCI6MX0.9lQYwJ6q0LpdFrROihosViel4wu3OFXWvBrDa5wn-E4" \
  -H "Content-Type: application/json" \
  -d '{"first_name": "UpdatedFirstName"}'

