from rest_framework import serializers
from .models import Switch

class SwitchSerializer(serializers.ModelSerializer):
    class Meta:
        model = Switch
        fields = ['id', 'name', 'is_on']

