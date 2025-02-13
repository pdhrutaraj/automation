curl -X POST http://127.0.0.1:8000/api/users/ \
  -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzM5MzU2NjQ2LCJpYXQiOjE3MzkzNTMwNDYsImp0aSI6Ijc1MTc4MzRjZWY2YjRkNjM5NWZkN2FjNTJlYTU2OTNkIiwidXNlcl9pZCI6MX0.tBwAmrVbCJ-VWviHdod7uwGLdYDvDzzfT_ZMG0RT4lg" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser1",
    "email": "my@example.com",
    "password": "mypassword",
    "first_name": "New",
    "last_name": "User"
  }'

