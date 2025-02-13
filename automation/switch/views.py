from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from .models import Switch
from .serializers import SwitchSerializer

class SwitchViewSet(viewsets.ModelViewSet):
    queryset = Switch.objects.all()
    serializer_class = SwitchSerializer
    permission_classes = [IsAuthenticated]  # Require authentication for all actions

    @action(detail=True, methods=['post'])
    def toggle(self, request, pk=None):
        """Toggle the switch on or off (authenticated users only)."""
        switch = self.get_object()
        switch.is_on = not switch.is_on
        switch.save()
        return Response({'status': f'Switch is now {"ON" if switch.is_on else "OFF"}'})


"""
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
        #Toggle the switch on or off.
        switch = self.get_object()
        switch.is_on = not switch.is_on
        switch.save()
        return Response({'status': f'Switch is now {"ON" if switch.is_on else "OFF"}'})

    @action(detail=True, methods=['post'])
    def turn_on(self, request, pk=None):
        #Turn the switch ON.
        switch = self.get_object()
        switch.is_on = True
        switch.save()
        return Response({'status': 'Switch turned ON'})

    @action(detail=True, methods=['post'])
    def turn_off(self, request, pk=None):
        #Turn the switch OFF.
        switch = self.get_object()
        switch.is_on = False
        switch.save()
        return Response({'status': 'Switch turned OFF'})
"""
