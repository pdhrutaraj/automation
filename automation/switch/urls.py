from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import SwitchViewSet

router = DefaultRouter()
router.register(r'switches', SwitchViewSet)

urlpatterns = [
    path('', include(router.urls)),
]

