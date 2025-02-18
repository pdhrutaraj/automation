django rest,simple jwt,postgres api server with user registration and management with user crud and an electrical switch simullation

Here’s a basic setup for a Django REST API server using Django REST Framework (DRF), Simple JWT, and PostgreSQL for user registration, user management (CRUD), and authentication.

Prerequisites
Python 3.8+
PostgreSQL
Django 4.0+
Django REST Framework
djangorestframework-simplejwt
Step 1: Install required packages

pip install django djangorestframework psycopg2 djangorestframework-simplejwt

Step 2: Create Django project and app

django-admin startproject myapi
cd myapi
python manage.py startapp users
Step 3: Configure settings.py
Update the INSTALLED_APPS and DATABASES sections in myapi/settings.py:

INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'rest_framework',
    'users',
]

REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': (
        'rest_framework_simplejwt.authentication.JWTAuthentication',
    ),
}

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': 'mydatabase',
        'USER': 'mydbuser',
        'PASSWORD': 'mypassword',
        'HOST': 'localhost',
        'PORT': '5432',
    }
}
Step 4: Create the User Serializer (users/serializers.py)

from rest_framework import serializers
from django.contrib.auth.models import User

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'first_name', 'last_name', 'is_staff', 'is_active']
Step 5: Create the User Views (users/views.py)

from rest_framework import viewsets, permissions, status
from rest_framework.response import Response
from django.contrib.auth.models import User
from .serializers import UserSerializer
from rest_framework.decorators import action
from rest_framework_simplejwt.tokens import RefreshToken

class UserViewSet(viewsets.ModelViewSet):
    queryset = User.objects.all()
    serializer_class = UserSerializer
    permission_classes = [permissions.IsAuthenticated]

    @action(detail=False, methods=['post'], permission_classes=[permissions.AllowAny])
    def register(self, request):
        data = request.data
        if User.objects.filter(username=data['username']).exists():
            return Response({"error": "Username already taken"}, status=status.HTTP_400_BAD_REQUEST)
        user = User.objects.create_user(
            username=data['username'],
            email=data.get('email', ''),
            password=data['password'],
            first_name=data.get('first_name', ''),
            last_name=data.get('last_name', '')
        )
        return Response(UserSerializer(user).data)

    @action(detail=True, methods=['post'])
    def deactivate(self, request, pk=None):
        user = self.get_object()
        user.is_active = False
        user.save()
        return Response({"status": "User deactivated"})
Step 6: Create URLs (users/urls.py)

from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import UserViewSet

router = DefaultRouter()
router.register(r'users', UserViewSet, basename='user')

urlpatterns = [
    path('', include(router.urls)),
]
Step 7: Register URLs (myapi/urls.py)

from django.contrib import admin
from django.urls import path, include
from rest_framework_simplejwt.views import (
    TokenObtainPairView,
    TokenRefreshView,
)

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/', include('users.urls')),
    path('api/token/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('api/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
]
Step 8: Apply migrations and run the server

python manage.py makemigrations
python manage.py migrate
python manage.py createsuperuser
python manage.py runserver

API Endpoints
POST /api/users/register/ — Register a new user
GET /api/users/ — List all users (admin access)
POST /api/token/ — Get JWT access and refresh tokens
POST /api/token/refresh/ — Refresh the access token
Want me to add more advanced features like email verification, role-based permissions, or password reset? Just let me know!

user management by superuser e.g. user crud operation

To implement user management by the superuser (CRUD operations on users), let’s update our Django REST API so that only superusers can perform full create, read, update, delete (CRUD) operations on users.

Step 1: Modify the UserViewSet in users/views.py

from rest_framework import viewsets, permissions, status
from rest_framework.response import Response
from django.contrib.auth.models import User
from .serializers import UserSerializer
from rest_framework.decorators import action

class IsSuperUser(permissions.BasePermission):
    """Custom permission to allow only superusers to access the view."""

    def has_permission(self, request, view):
        return request.user and request.user.is_superuser

class UserViewSet(viewsets.ModelViewSet):
    queryset = User.objects.all()
    serializer_class = UserSerializer
    permission_classes = [IsSuperUser]

    def create(self, request, *args, **kwargs):
        """Create a new user (superuser only)."""
        data = request.data
        if User.objects.filter(username=data['username']).exists():
            return Response({"error": "Username already taken"}, status=status.HTTP_400_BAD_REQUEST)
        
        user = User.objects.create_user(
            username=data['username'],
            email=data.get('email', ''),
            password=data['password'],
            first_name=data.get('first_name', ''),
            last_name=data.get('last_name', '')
        )
        return Response(UserSerializer(user).data, status=status.HTTP_201_CREATED)

    def update(self, request, *args, **kwargs):
        """Update a user's information (superuser only)."""
        partial = kwargs.pop('partial', False)
        instance = self.get_object()
        serializer = self.get_serializer(instance, data=request.data, partial=partial)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(serializer.data)

    def destroy(self, request, *args, **kwargs):
        """Delete a user (superuser only)."""
        user = self.get_object()
        user.delete()
        return Response({"status": "User deleted successfully"}, status=status.HTTP_204_NO_CONTENT)

    @action(detail=False, methods=['get'])
    def active_users(self, request):
        """List only active users."""
        active_users = User.objects.filter(is_active=True)
        serializer = self.get_serializer(active_users, many=True)
        return Response(serializer.data)
Explanation
Custom Permission (IsSuperUser): Ensures only superusers can access the UserViewSet.
CRUD Operations: Superusers can create, read, update, and delete user records.
Custom Action (active_users): Returns a list of only active users.
Step 2: Update urls.py (users/urls.py)

from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import UserViewSet

router = DefaultRouter()
router.register(r'users', UserViewSet, basename='user')

urlpatterns = [
    path('', include(router.urls)),
]
Step 3: Test Endpoints
Here’s how the superuser can manage users via the API:

GET /api/users/ — List all users
POST /api/users/ — Create a new user

{
  "username": "newuser",
  "email": "newuser@example.com",
  "password": "password123",
  "first_name": "New",
  "last_name": "User"
}
PUT /api/users/{id}/ — Update a user’s details
DELETE /api/users/{id}/ — Delete a user
GET /api/users/active_users/ — List all active users
Optional Features
Role-based permissions (allow superusers and staff members to manage different user roles)
User filtering and search (e.g., filter by is_active, date_joined)
Email verification for new users
Want me to extend this with any of these features? 😊

Here’s how you can test the user management by superuser using curl.

Step 1: Obtain JWT Token
First, get your access token using curl with username and password.

curl -X POST http://127.0.0.1:8000/api/token/ \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "adminpassword"}'
Response:

{
  "access": "YOUR_ACCESS_TOKEN",
  "refresh": "YOUR_REFRESH_TOKEN"
}
Copy the "access" token. You’ll use it for authentication in the following requests.

Step 2: List All Users (GET Request)

curl -X GET http://127.0.0.1:8000/api/users/ \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
Response:

[
  {
    "id": 1,
    "username": "admin",
    "email": "admin@example.com",
    "first_name": "Admin",
    "last_name": "User",
    "is_staff": true,
    "is_active": true
  },
  {
    "id": 2,
    "username": "testuser",
    "email": "testuser@example.com",
    "first_name": "Test",
    "last_name": "User",
    "is_staff": false,
    "is_active": true
  }
]
Step 3: Create a New User (POST Request)

curl -X POST http://127.0.0.1:8000/api/users/ \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "newuser",
    "email": "newuser@example.com",
    "password": "password123",
    "first_name": "New",
    "last_name": "User"
  }'
Response:

{
  "id": 3,
  "username": "newuser",
  "email": "newuser@example.com",
  "first_name": "New",
  "last_name": "User",
  "is_staff": false,
  "is_active": true
}
Step 4: Update a User (PUT Request)
Update the details of a specific user (e.g., id = 3).

curl -X PUT http://127.0.0.1:8000/api/users/3/ \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "first_name": "Updated",
    "last_name": "User"
  }'
Response:

{
  "id": 3,
  "username": "newuser",
  "email": "newuser@example.com",
  "first_name": "Updated",
  "last_name": "User",
  "is_staff": false,
  "is_active": true
}
Step 5: Delete a User (DELETE Request)

curl -X DELETE http://127.0.0.1:8000/api/users/3/ \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
Response:

{"status": "User deleted successfully"}
Step 6: List Active Users (GET Request)

curl -X GET http://127.0.0.1:8000/api/users/active_users/ \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
Let me know if you want to add tests for error handling, filtering users, or automated testing using Django’s TestCase class!


./update_user.sh 
{"username":["This field is required."]

The error {"username":["This field is required."]} typically occurs when the username field is missing in the request payload for updating the user. By default, Django REST Framework expects all required fields when using PUT (which replaces the whole object). If you want to update only specific fields, use a PATCH request instead of PUT.

Fix 1: Use PATCH Instead of PUT
PATCH allows you to update specific fields without needing to send all fields.

Example with curl:

curl -X PATCH http://127.0.0.1:8000/api/users/3/ \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"first_name": "UpdatedFirstName"}'
Fix 2: Ensure username is Sent with PUT
If you want to stick with PUT, you must send the complete user object, including the username and other required fields.

Example:

curl -X PUT http://127.0.0.1:8000/api/users/3/ \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "newuser",
    "email": "newuser@example.com",
    "first_name": "UpdatedFirstName",
    "last_name": "UpdatedLastName",
    "is_staff": false,
    "is_active": true
  }'
Explanation:
PUT requires the full object representation, while PATCH allows partial updates.
The error message indicates the required field username is missing, meaning your update_user.sh script might not be passing all fields.
Need Help with the update_user.sh Script?
If you want me to check or modify that script, feel free to share it! 😊


add app in project simulating electrical switch with property on and off

To create an app in your Django project that simulates an electrical switch with properties like on and off, we’ll follow these steps:

Create a switch app.
Define a Switch model with an is_on Boolean field.
Add API endpoints to control the switch (turn it on/off and check its status).
Optionally, create a user-friendly admin interface.
Step 1: Create the switch app

python manage.py startapp switch
Add switch to INSTALLED_APPS in settings.py:

INSTALLED_APPS = [
    ...
    'switch',
]
Step 2: Create the Switch Model (switch/models.py)

from django.db import models

class Switch(models.Model):
    name = models.CharField(max_length=100, unique=True)
    is_on = models.BooleanField(default=False)

    def __str__(self):
        return f"{self.name} - {'ON' if self.is_on else 'OFF'}"
Step 3: Create a Serializer (switch/serializers.py)

from rest_framework import serializers
from .models import Switch

class SwitchSerializer(serializers.ModelSerializer):
    class Meta:
        model = Switch
        fields = ['id', 'name', 'is_on']
Step 4: Create Views for the API (switch/views.py)

from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from .models import Switch
from .serializers import SwitchSerializer

class SwitchViewSet(viewsets.ModelViewSet):
    queryset = Switch.objects.all()
    serializer_class = SwitchSerializer

    @action(detail=True, methods=['post'])
    def toggle(self, request, pk=None):
        """Toggle the switch on or off."""
        switch = self.get_object()
        switch.is_on = not switch.is_on
        switch.save()
        return Response({'status': f'Switch is now {"ON" if switch.is_on else "OFF"}'})

    @action(detail=True, methods=['post'])
    def turn_on(self, request, pk=None):
        """Turn the switch ON."""
        switch = self.get_object()
        switch.is_on = True
        switch.save()
        return Response({'status': 'Switch turned ON'})

    @action(detail=True, methods=['post'])
    def turn_off(self, request, pk=None):
        """Turn the switch OFF."""
        switch = self.get_object()
        switch.is_on = False
        switch.save()
        return Response({'status': 'Switch turned OFF'})
Step 5: Configure URLs (switch/urls.py)

from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import SwitchViewSet

router = DefaultRouter()
router.register(r'switches', SwitchViewSet)

urlpatterns = [
    path('', include(router.urls)),
]
Update the project-level urls.py:

from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/', include('switch.urls')),
]
Step 6: Migrate and Create Sample Switches

python manage.py makemigrations
python manage.py migrate
Create a sample switch using Django shell:

python manage.py shell

from switch.models import Switch
Switch.objects.create(name='Living Room Light')
Switch.objects.create(name='Kitchen Light')
exit()
Step 7: Test the API with curl
List all switches

curl -X GET http://127.0.0.1:8000/api/switches/
Toggle a switch (ID = 1)

curl -X POST http://127.0.0.1:8000/api/switches/1/toggle/
Turn on a switch (ID = 2)

curl -X POST http://127.0.0.1:8000/api/switches/2/turn_on/
Turn off a switch (ID = 1)

curl -X POST http://127.0.0.1:8000/api/switches/1/turn_off/
Optional Enhancements
Permissions: Allow only authenticated users to control the switch.
WebSocket Integration: Get real-time updates when the switch state changes.
Frontend Component: Add a button in your React frontend to control the switch.
Want to extend this further? 😊


modern nice looking ui for front end  using react for above project with login,logout and landing pages 

Here’s a step-by-step guide to build a modern, nice-looking React frontend for your Django API project that includes:

React App Setup
React Router for Navigation
Login and Logout Pages
Landing Page
Dashboard with Switch Control
Integration with Django API using Axios
Dark Mode and Responsive Design
Step 1: Create the React App
Run the following command to create a new React app using create-react-app with Tailwind CSS for styling.

npx create-react-app switch-frontend
cd switch-frontend
npm install axios react-router-dom tailwindcss @headlessui/react @heroicons/react
npx tailwindcss init
Configure tailwind.config.js:

module.exports = {
  content: ['./src/**/*.{js,jsx,ts,tsx}'],
  theme: {
    extend: {},
  },
  plugins: [],
};
Add Tailwind to index.css:

@tailwind base;
@tailwind components;
@tailwind utilities;
Step 2: Project Structure
Create the following folders and files inside src:

src/
  ├── components/
  │     ├── Navbar.jsx
  │     ├── SwitchCard.jsx
  ├── pages/
  │     ├── Login.jsx
  │     ├── LandingPage.jsx
  │     ├── Dashboard.jsx
  ├── utils/
  │     └── api.js
  ├── App.js
  ├── index.css
Step 3: Create a Navbar (components/Navbar.jsx)

import { Link } from 'react-router-dom';

const Navbar = ({ onLogout }) => {
  return (
    <nav className="bg-gray-800 p-4 text-white flex justify-between items-center">
      <div className="text-2xl font-bold">Smart Switch</div>
      <div className="space-x-4">
        <Link to="/" className="hover:underline">Home</Link>
        <Link to="/dashboard" className="hover:underline">Dashboard</Link>
        <button onClick={onLogout} className="bg-red-500 px-4 py-2 rounded">Logout</button>
      </div>
    </nav>
  );
};

export default Navbar;
Step 4: Create the Landing Page (pages/LandingPage.jsx)

import { Link } from 'react-router-dom';

const LandingPage = () => {
  return (
    <div className="h-screen bg-gray-100 flex flex-col justify-center items-center">
      <h1 className="text-5xl font-bold mb-8">Welcome to Smart Switch Control</h1>
      <p className="text-lg mb-6">Manage your smart switches from anywhere!</p>
      <Link to="/login" className="bg-blue-500 text-white px-6 py-3 rounded-lg">Get Started</Link>
    </div>
  );
};

export default LandingPage;
Step 5: Create the Login Page (pages/Login.jsx)

import { useState } from 'react';
import axios from '../utils/api';
import { useNavigate } from 'react-router-dom';

const Login = ({ setToken }) => {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      const response = await axios.post('/token/', { username, password });
      setToken(response.data.access);
      navigate('/dashboard');
    } catch (error) {
      alert('Invalid credentials');
    }
  };

  return (
    <div className="h-screen flex items-center justify-center bg-gray-100">
      <form onSubmit={handleSubmit} className="bg-white p-8 rounded-lg shadow-lg">
        <h2 className="text-2xl font-bold mb-4">Login</h2>
        <div className="mb-4">
          <label className="block text-gray-700">Username</label>
          <input
            type="text"
            className="w-full p-2 border rounded"
            value={username}
            onChange={(e) => setUsername(e.target.value)}
          />
        </div>
        <div className="mb-4">
          <label className="block text-gray-700">Password</label>
          <input
            type="password"
            className="w-full p-2 border rounded"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
          />
        </div>
        <button type="submit" className="w-full bg-blue-500 text-white p-2 rounded">Login</button>
      </form>
    </div>
  );
};

export default Login;
Step 6: Create the Dashboard (pages/Dashboard.jsx)

import { useEffect, useState } from 'react';
import axios from '../utils/api';
import SwitchCard from '../components/SwitchCard';

const Dashboard = () => {
  const [switches, setSwitches] = useState([]);

  useEffect(() => {
    const fetchSwitches = async () => {
      const response = await axios.get('/switches/');
      setSwitches(response.data);
    };
    fetchSwitches();
  }, []);

  return (
    <div className="p-8">
      <h1 className="text-3xl font-bold mb-6">Dashboard</h1>
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {switches.map((sw) => (
          <SwitchCard key={sw.id} switchData={sw} />
        ))}
      </div>
    </div>
  );
};

export default Dashboard;
Step 7: Create the Switch Card (components/SwitchCard.jsx)

import axios from '../utils/api';

const SwitchCard = ({ switchData }) => {
  const handleToggle = async () => {
    await axios.post(`/switches/${switchData.id}/toggle/`);
    window.location.reload(); // Reload to update the switch state
  };

  return (
    <div className="bg-white p-6 rounded-lg shadow-lg">
      <h2 className="text-xl font-bold mb-4">{switchData.name}</h2>
      <p className="mb-4">Status: <strong>{switchData.is_on ? 'ON' : 'OFF'}</strong></p>
      <button
        onClick={handleToggle}
        className={`px-4 py-2 rounded ${switchData.is_on ? 'bg-red-500' : 'bg-green-500'} text-white`}
      >
        Toggle Switch
      </button>
    </div>
  );
};

export default SwitchCard;
Step 8: Axios Setup (utils/api.js)

import axios from 'axios';

const api = axios.create({
  baseURL: 'http://127.0.0.1:8000/api/',
});

export default api;
Step 9: Update App.js

import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { useState } from 'react';
import Navbar from './components/Navbar';
import LandingPage from './pages/LandingPage';
import Login from './pages/Login';
import Dashboard from './pages/Dashboard';

function App() {
  const [token, setToken] = useState(null);

  const handleLogout = () => {
    setToken(null);
  };

  return (
    <Router>
      {token && <Navbar onLogout={handleLogout} />}
      <Routes>
        <Route path="/" element={<LandingPage />} />
        <Route path="/login" element={<Login setToken={setToken} />} />
        <Route path="/dashboard" element={token ? <Dashboard /> : <LandingPage />} />
      </Routes>
    </Router>
  );
}

export default App;
Step 10: Start the React App

npm start
Features Included:
Modern UI with Tailwind CSS
React Router Navigation
Login, Logout, Landing Page, and Dashboard
Switch Control and Toggle API Integration
Responsive Design
Want to add dark mode, toast notifications, or better token storage (localStorage)? Let me know! 😊

sql

prakash@DESKTOP-C26OAB4:~/automation/automation$ sudo -u postgres psql
[sudo] password for prakash:
psql (17.2 (Ubuntu 17.2-1.pgdg24.04+1))
Type "help" for help.

postgres=# create database automationdb;
CREATE DATABASE
postgres=# create user automationdbowner with password 'automationdbowner';
CREATE ROLE
postgres=# grant all on database automationdb to automationdbowner;
GRANT
postgres=# GRANT ALL PRIVILEGES ON DATABASE automationdb TO automationdbowner;
GRANT
postgres=#
postgres=# alter database automationdb owner to automationdbowner;
ALTER DATABASE
postgres=# \q


